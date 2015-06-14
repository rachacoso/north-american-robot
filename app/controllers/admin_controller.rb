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

		if Display.all.first.blank?
			@display_info = Display.new
	  else
			@display_info = Display.all.first
		end
    
  end

  def brands_index
    brands = Brand.all.sort_by{ |b| b.company_name.to_s }
    @brands = do_kaminari_array(brands, params[:page])
  end

  def brand_view
    @brand = Brand.find(params[:id])
  end

  def distributors_index
    distributors = Distributor.all.sort_by{ |d| d.company_name.to_s }
    @distributors = do_kaminari_array(distributors, params[:page])
  end

  def distributor_view
    @distributor = Distributor.find(params[:id])
  end

  def new_bulk_upload

  end

  def do_bulk_upload
    if params[:file] && params[:user_type] && params[:sector]
      @user_type = params[:user_type]
      @sector = params[:sector]
      uploaded_file = params[:file]
      @list = []
      @rejected = []
      case @user_type
      when "distributor"
        uploaded_file.open.each_line do |line|
          data = line.split(/\t/)
          emailcheck = data[7]
          if emailcheck.blank? || !emailcheck[/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i] #skip line if no email or not an email address
            @rejected << data
            next 
          end
          # ufounded, ucompany_name, uaddr1, uaddr2, ucity, uzip, ucountry, uemail, uwebsite, ulinkedin, ufacebook = data.map { |p| p }
          if User.where(email: emailcheck).first
            data << "skipped!"
            @list << data          
            next
          else
            create_user('distributor', data)
            data << "created!#{data[7]}"
            @list << data
          end
        end
      when "brand"                           
        uploaded_file.open.each_line do |line|
          data = line.split(/\t/)
          emailcheck = data[3]
          if emailcheck.blank? || !emailcheck[/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i] #skip line if no email or not an email address
            @rejected << data
            next 
          end
          # ufounded, ucompany_name, uwebsite, uemail, ucity, ustate, ulinkedin, ufacebook = data.map { |p| p }
          if User.where(email: emailcheck).first
            data << "skipped!"
            @list << data          
            next
          else
            create_user('brand', data)
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

  def do_kaminari_array(collection, page = 1)
    return Kaminari.paginate_array(collection).page(page).per(20)
  end

  def create_user(usertype, data)
    if usertype == 'distributor' || usertype == 'brand' # restrict to only allowed values
      case usertype
      when 'distributor'
        ufounded, ucompany_name, uaddr1, uaddr2, ucity, uzip, ucountry, uemail, uwebsite, ulinkedin, ufacebook = data.map { |p| p }
        ustate = nil
      when 'brand'
        ufounded, ucompany_name, uwebsite, uemail, ucity, ustate, ulinkedin, ufacebook = data.map { |p| p }
        uaddr1 = nil
        uaddr2 = nil
        uzip = nil
        ucountry = "United States"
      end
      user = User.new
      user.build_contact
      user.email = uemail
      user.password = "waterorangeeaglehill"
      user.password_confirmation = "waterorangeeaglehill"
      createusertype = "create_" + usertype
      brand_or_distributor = user.send(createusertype) # create relation
      brand_or_distributor.create_address
      brand_or_distributor.contacts << Contact.new(email: uemail)
      brand_or_distributor.sectors << Sector.find(@sector)
      brand_or_distributor.update(year_established: Date.new(ufounded.to_i), company_name: ucompany_name, country_of_origin: ucountry, website: uwebsite, facebook: ufacebook, linkedin: ulinkedin)
      usertype == 'distributor' ? brand_or_distributor.export_countries.find_or_initialize_by(country: ucountry) : ""
      brand_or_distributor.create_address(address1: uaddr1, address2: uaddr2, city: ucity, postcode: uzip, country: ucountry, state: ustate)
      user.save!
    end
  end

end