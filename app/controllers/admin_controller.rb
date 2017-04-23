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
    @key_retailer = KeyRetailer.all
    @trend = Trend.all


  	@new_sector = Sector.new
    @new_subsector = Subsector.new
  	@new_channel = Channel.new
  	# @new_country = Country.new
    @new_company_size = CompanySize.new
    @new_trend = Trend.new
    @new_key_retailer = KeyRetailer.new

		if Display.all.first.blank?
			@display_info = Display.new
	  else
			@display_info = Display.all.first
		end
    
  end

  def brands_index
    brands = Brand.all
    if params[:q] && !params[:q].blank?
      @query = params[:q]
      brands = brands.where(company_name: /#{@query}/i )
    end
    brands = brands.sort_by{ |d| d.company_name.to_s }
    @brands = do_kaminari_array(brands, params[:page])
  end

  def brand_view
    @brand = Brand.find(params[:id])
  end

  def distributors_index
    distributors = Distributor.all
    if params[:q] && !params[:q].blank?
      @query = params[:q]
      distributors = distributors.where(company_name: /#{@query}/i )
    end
    distributors = distributors.sort_by{ |d| d.company_name.to_s }
    @distributors = do_kaminari_array(distributors, params[:page])
    @distributors_margin = Distributor.margin_pending
    @distributors_payment_terms = Distributor.payment_terms_pending
  end

  def distributor_view
    @distributor = Distributor.find(params[:id])
  end

  def retailers_index
    retailers = Retailer.all
    if params[:q] && !params[:q].blank?
      @query = params[:q]
      retailers = retailers.where(company_name: /#{@query}/i )
    end
    retailers = retailers.sort_by{ |d| d.company_name.to_s }
    @retailers = do_kaminari_array(retailers, params[:page])
    @retailers_margin = Retailer.margin_pending
    @retailers_payment_terms = Retailer.payment_terms_pending
  end

  def retailer_view
    @retailer = Retailer.find(params[:id])
  end

  def orders_pre_search_brands

    @list = Hash.new
    @list['suggestions'] = Array.new

    brands = Brand.activated

    if !params[:query].blank?
      q = params[:query]
      brands = brands.select {|brand| brand[:company_name][/#{q}/i] }
    end
    brands.each do |p|
      @list['suggestions'] << { "value": p[:company_name], "data": p[:company_name] }
    end

    render json: @list

  end

  def orders_pre_search_buyers

    @list = Hash.new
    @list['suggestions'] = Array.new

    retailers = Retailer.activated
    distributors = Distributor.activated

    if !params[:query].blank?
      q = params[:query]
      retailers = retailers.select {|retailer| retailer[:company_name][/#{q}/i] }
      distributors = distributors.select {|distributor| distributor[:company_name][/#{q}/i] }
    end
    retailers.each do |p|
      @list['suggestions'] << { "value": p[:company_name], "data": p[:company_name] }
    end
    distributors.each do |p|
      @list['suggestions'] << { "value": p[:company_name], "data": p[:company_name] }
    end

    render json: @list

  end

  def orders_search

    @orders = []

    if params[:query_retailer_po].present?
      q = params[:query_retailer_po]
      @search_type = 'retailer_po'
      @orders = Order.all.order_search(query: [q], type: @search_type, show_completed: params[:show_completed], user: @current_user)
    elsif params[:query_landing_id].present?
      q = params[:query_landing_id]
      @search_type = 'landing_id'
      @orders = Order.all.order_search(query: [q], type: @search_type, show_completed: params[:show_completed], user: @current_user)
      @reset_buyer_brand = true
    elsif params[:query_brands].present? && params[:query_buyers].present?
      brand_query = params[:query_brands]
      buyer_query = params[:query_buyers]
      @search_type = 'buyer_brand'
      @orders = Order.all.order_search(query: [brand_query,buyer_query], type: @search_type, show_completed: params[:show_completed], user: @current_user)      
    elsif params[:query_buyers].present?
      q = params[:query_buyers]
      @search_type = 'buyer'
      @orders = Order.all.order_search(query: [q], type: @search_type, show_completed: params[:show_completed], user: @current_user)
    elsif params[:query_brands].present?
      q = params[:query_brands]
      @search_type = 'brand'
      @orders = Order.all.order_search(query: [q], type: @search_type, show_completed: params[:show_completed], user: @current_user)
    else
      @orders = params[:show_completed] ? Order.all : Order.in_progress
    end

  end

  def orders_index
    @group = params[:group]
    case @group
    when "search"
      @orders = Order.in_progress
    when "brands"
      @orders = {}
      brands = Brand.activated.order_by(:company_name => 'asc')
      brands.each do |brand|
        next if brand.orders.blank?
        @orders[brand] = brand.orders  
      end
    when "buyers"
      @orders = {}
      retailers = Retailer.activated.order_by(:company_name => 'asc')
      distributors = Distributor.activated.order_by(:company_name => 'asc')
      buyers = retailers + distributors
      buyers.each do |buyer|
        next if buyer.orders.blank?
        @orders[buyer] = buyer.orders  
      end
    else
      @orders = {}
    end
  end

  def order_view
    @order = Order.find(params[:id])
  end

  def order_destroy
    @order = Order.find(params[:id])
    if params[:confirm].to_i == 1
      if @order.can_be_deleted?
        @success = true if @order.destroy!
      end
    end
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

  def add_user
    if params[:id]
      id = params[:id]
      b_or_d = Brand.find(id) || Distributor.find(id) || Retailer.find(id)
      if !params[:user][:email].blank?

        if User.where(email: params[:user][:email]).exists?
          flash[:error] = "That email address is already in use"
          redirect_to eval("admin_#{b_or_d.class.to_s.downcase}_view_path"), :alert => "That email/username is taken."
        else
          pwd = SecureRandom.urlsafe_base64
          user = User.new
          user.build_contact
          user.email = params[:user][:email]
          user.password = pwd
          user.password_confirmation = pwd
          user.contact.firstname = params[:contact][:firstname]
          user.contact.lastname = params[:contact][:lastname]
          user.company = b_or_d
          user.send("#{user.company_type.downcase}=", b_or_d)
          user.save!
          # b_or_d.users << user
          redirect_to eval("admin_#{b_or_d.class.to_s.downcase}_view_path")
        end

      else
        redirect_to eval("admin_#{b_or_d.class.to_s.downcase}_view_path"), :alert => "Enter an email address"
      end

    end
  end

  def delete_user
    if params[:id]
      if user = User.find(params[:id])
        user.destroy
      end
    end
    redirect_to :back
  end

  private

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
      user.password = ENV['BULK_UPLOAD_PWD']
      user.password_confirmation = ENV['BULK_UPLOAD_PWD']
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