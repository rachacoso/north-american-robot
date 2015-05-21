class AdminController < ApplicationController
  
  #restrict to administrators only
  before_action :administrators_only

  require 'csv'
  CSV::Converters[:blank_to_nil] = lambda do |field|
    field && field.empty? ? nil : field
  end

  def index
  	@sector = Sector.all
  	@channel = Channel.all
  	# @country = Country.all
    @company_size = CompanySize.all

  	@new_sector = Sector.new
  	@new_channel = Channel.new
  	# @new_country = Country.new
    @new_company_size = CompanySize.new

		# if Display.all.first.blank?
		# 	@display_info = Display.new
	 #  else
		# 	@display_info = Display.all.first
		# end
    
  end

  def new_bulk_upload

  end

  def do_bulk_upload
    if params[:file] && params[:user_type] && params[:sector]

      @user_type = params[:user_type]
      @sector = params[:sector]
      uploaded_file = params[:file]
      @list = []

      case @user_type
      when "distributor"

        uploaded_file.open.each_line do |line|
          data = line.split(/\t/)
          ufounded, ucompany_name, uaddr1, uaddr2, ucity, uzip, ucountry, uemail, uwebsite, ulinkedin, ufacebook = data.map { |p| p }

          if User.where(email: uemail).first
            data << "skipped!"
            @list << data          
            next
          else

            user = User.new
            
            user.build_user_profile
            user.email = uemail
            user.password = "GlobalGoods"
            user.password_confirmation = "GlobalGoods"
            user.save!
            user.create_distributor

            d = user.distributor

            cinfo = d.contact_info
            cinfo.email = uemail
            cinfo.address1 = uaddr1
            cinfo.address2 = uaddr2
            cinfo.city = ucity
            cinfo.postcode = uzip
            cinfo.country = ucountry
            cinfo.save
            d.sectors << Sector.find(@sector)
            d.update(year_established: Date.new(ufounded.to_i), company_name: ucompany_name, country_of_origin: ucountry, website: uwebsite, facebook: ufacebook, linkedin: ulinkedin)

            d.export_countries.find_or_initialize_by(country: ucountry)
            
            user.save!
            d.save!

            data << "created!"
            @list << data
          end

        end

      when "brand"                           

        uploaded_file.open.each_line do |line|
          data = line.split(/\t/)
          ufounded, ucompany_name, uwebsite, uemail, ucity, ustate, ulinkedin, ufacebook = data.map { |p| p }

            # data << "test!"
            # @list << data    

          if User.where(email: uemail).first
            data << "skipped!"
            @list << data          
            next
          else

            user = User.new
            
            user.build_user_profile
            user.email = uemail
            user.password = "GlobalGoods"
            user.password_confirmation = "GlobalGoods"
            user.save!
            user.create_brand

            b = user.brand

            cinfo = b.contact_info
            cinfo.email = uemail
            cinfo.city = ucity
            cinfo.country = "United States"
            cinfo.save
            b.sectors << Sector.find(@sector) #baby/kids (HEROKU)
            b.update(year_established: Date.new(ufounded.to_i), company_name: ucompany_name, country_of_origin: "United States", website: uwebsite, facebook: ufacebook, linkedin: ulinkedin)
            
            user.save!
            b.save!

            data << "created!"
            @list << data
          end

        end


      end
    
    end

    # respond_to do |format|
    #   format.html
    #   format.js
    # end 

  end

  private
  
  def administrators_only
    unless @current_user.administrator
      redirect_to dashboard_url
    end
  end

end