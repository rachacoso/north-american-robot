class BrandsController < ApplicationController

	before_action :check_usertype, only: [:edit, :public_profile, :full_profile, :update]
	before_action :administrators_only, only: [:adminupdate]
	skip_before_action :require_login, only: [:index, :view, :preview, :search]

	# V2 ACTIONS

	def index

		# get only beauty sector brands
		beauty_sector = Sector.where(name: 'Beauty / Personal Care').first

		if params[:filter]
			if params[:type] == "t"
				@type = "t"
				@filtered = Trend.find(params[:filter])
				@filtered_brands = Brand.activated.international.where(trend_ids: @filtered.id)
				@brand_chunk = Trend.all.sort_by { |p| p.name }
			elsif params[:type] == "kr"
				@type = "kr"
				@filtered = KeyRetailer.find(params[:filter])
				@filtered_brands = Brand.activated.international.where(key_retailer_ids: @filtered.id)
				@brand_chunk = KeyRetailer.all.sort_by { |p| p.name }
			elsif params[:type] == "c"
				@type = "c"
				@filtered = Subsector.find(params[:filter])
				@filtered_brands = Brand.activated.international.where(subsector_ids: @filtered.id)
				@brand_chunk = Subsector.where(sector_id: beauty_sector.id).uniq { |p| p.name }.sort_by { |p| p.name }
			end
		else
			if params[:type] == "t"
				@type = "t"
				@brand_chunk = Trend.all.sort_by { |p| p.name }
			elsif params[:type] == "kr"
				@type = "kr"
				@brand_chunk = KeyRetailer.all.sort_by { |p| p.name }
			else #default to subsector
				@type = "c"
				@brand_chunk = Subsector.where(sector_id: beauty_sector.id).uniq { |p| p.name }.sort_by { |p| p.name }
			end
		end

	end


	def search
		if params[:q].present?
			@query = params[:q]
			@searchresults = Brand.activated.international.where(company_name: /#{@query}/i)
		else
			redirect_to brands_url
		end
	end

	def view

		@profile = Brand.find(params[:id])
		# GALLERY
    @product_list = @profile.products.pluck(:id)
    @product_photos = ProductPhoto.where(:photographable_id.in => @product_list).shuffle[0..8]
    @brand_photos = @profile.brand_photos.shuffle[0..8]
    @gallery = @product_photos.concat @brand_photos

	  unless @current_user
			session[:persisted_redirect] = view_brand_url(@profile)
	  end

    respond_to do |format|
      format.html
      format.js
    end

	end


  def preview

		@profile = Brand.find(params[:id])
		# GALLERY
    @product_list = @profile.products.pluck(:id)
    @product_photos = ProductPhoto.where(:photographable_id.in => @product_list).shuffle[0..8]
    @brand_photos = @profile.brand_photos.shuffle[0..8]
    @gallery = @product_photos.concat @brand_photos

	  unless @current_user
			session[:persisted_redirect] = view_brand_url(@profile)
	  end

    respond_to do |format|
      format.html { redirect_to view_brand_url(@profile) } 
      format.js
    end

  end

  # ORIGINAL ACTIONS


	def list
		beauty_sector = Sector.where(name: 'Beauty / Personal Care').first

		# :messages.last.from_user => {'$ne' => current_user}
		brands = Brand.activated.order_by(:company_name => 'asc')
		# brands = Brand.activated
		@list = Hash.new
		@list['suggestions'] = Array.new

		if !params[:query].blank?
			q = params[:query]
			brands = brands.any_of({"company_name": /#{q}/i})
		end

		brands.each do |b|
			unless b.company_name.blank?
				@list['suggestions'] << { "value": b.company_name, "data": b.id.to_s }
			end
		end


		render json: @list

	end


	def edit

		@brand = @current_user.brand

		@current_products = @brand.products.where(current: true) rescue nil
		@past_products = @brand.products.where(current: false) rescue nil
		@new_product = Product.new
		
		@trade_shows = @brand.trade_shows rescue nil
		@new_trade_show = TradeShow.new

		@press_hits = @brand.press_hits rescue nil
		@new_press_hit = PressHit.new

		@patents = @brand.patents rescue nil
		@new_patent = Patent.new

		@trademarks = @brand.trademarks rescue nil
		@new_trademark = Trademark.new

		@compliances = @brand.compliances rescue nil
		@new_compliance = Compliance.new

		@channel_capacities = @brand.channel_capacities rescue nil
		@new_channel_capacity = ChannelCapacity.new

		@export_countries = @brand.export_countries rescue nil
		@new_export_country = ExportCountry.new				

		#FOR TAGS
		@tags = @brand.tags rescue nil

		# BUILD 'PRODUCT_TAGS' HASH WITH PRODUCT'S TAGS
		@product_tags = Hash.new
		@brand.products.each do |product|
			@product_tags[product.id] = product.tags
		end
		

	end

	def public_profile
		@profile = @current_user.brand
	end

	def full_profile
		@profile = @current_user.brand

		# GALLERY
    @product_list = @profile.products.pluck(:id)
    @product_photos = ProductPhoto.where(:photographable_id.in => @product_list).shuffle[0..8]
    @brand_photos = @profile.brand_photos.shuffle[0..8]
    @gallery = @product_photos.concat @brand_photos

	end

	def update

		brand = @current_user.brand

		# set general fields
		brand.update(brand_parameters)

		# set other fields

		# set year established
		if params[:year_established]
			brand.update(year_established: Date.new(params[:year_established].to_i))
		end

		if params[:key_retailers]
			# set key_retailers
			assigned_key_retailers = KeyRetailer.find(params[:key_retailers].values) rescue []
			unless assigned_key_retailers.blank?
				brand.key_retailers = [] # clear current ones before update
			end
			assigned_key_retailers.each do |kr|
				brand.key_retailers << kr
			end
		end

		if params[:trends]
			# set trends
			assigned_trends = Trend.find(params[:trends].values) rescue []
			unless assigned_trends.blank?
				brand.trends = [] # clear current ones before update
			end
			assigned_trends.each do |t|
				brand.trends << t
			end
		end

		if params[:sectors]
			# set sectors
			assigned_sectors = Sector.find(params[:sectors].values) rescue []
			unless assigned_sectors.blank?
				brand.sectors = [] # clear current ones before update
			end
			assigned_sectors.each do |s|
				brand.sectors << s
			end
		end

		if params[:subsectors]
			# set subsectors
			assigned_subsectors = Subsector.find(params[:subsectors].values) rescue []
			subsector_parents = assigned_subsectors.map { |s| s.sector }

			brand.subsectors = [] # clear current ones before update
			assigned_subsectors.each do |s|
				brand.subsectors << s
			end

			subsector_parents.each do |p|
				unless brand.sectors.find(p)
					brand.sectors << p
				end
			end

		end

		if params[:channels]
			# set channels
			assigned_channels = Channel.find(params[:channels].values) rescue []

			# delete channel capacities for disabled channels
			brand.channel_capacities.each do |cc|
				if !params[:channels].values.include?(cc.channel_id)
					cc.delete
				end
			end
			# initiate channel capacities for any new added
			assigned_channels.each do |ac|
				brand.channel_capacities.find_or_create_by(channel_id: ac.id)
			end

			unless assigned_channels.blank? 
				brand.channels = [] # clear current ones before update
			end
			assigned_channels.each do |s|
				brand.channels << s
			end
		end

		if params[:customchannels]

			params[:customchannels].each do |k,v|
				cname = v
				cchannel = brand.channel_capacities.find_or_create_by(custom_channel_name: cname, channel_id: 0)
				cchannel.save
			end

		end


		if brand.save
			# successful

      # update completeness
      brand.update_completeness

			# allow redirect via passed parameter only if in this array else redirect to the first onboard screen
			allowable_redirect = [
				'two',
				'three',
				'four'
				# 'six',
				# 'seven',
				# 'eight',
				# 'complete'
			]

			if params[:redirect]
				if allowable_redirect.include? params[:redirect]
					if params[:redirect] == 'complete'
						redirect_to dashboard_url
					else
						redir = "onboard_brand_#{params[:redirect]}_url"
						redirect_to send(redir)
					end
					
				else
					redirect_to onboard_brand_one_url
					# allow redirect via passed parameter only if in 'allowed' array, else redirect to the first onboard screen
				end
			elsif params[:redirect_anchor]
				redirect_to brand_url + "#" + params[:redirect_anchor] 
			else
				redirect_to brand_url
			end

		else
			# not successful  
			# STILL INCOMPLETE NEED TO ADD VALIDATIONS
			flash[:error] = "Sorry, there were errors"

			redirect_to brand_url, :flash => {
				:name_error => brand.errors[:company_name].first
			}

		end

	end	

  def adminupdate
    brand = Brand.find(params[:id])
    brand.update!(admin_brand_parameters)
    redirect_to admin_brand_view_url(brand)
  end

  private
  def brand_parameters
    params.require(:brand).permit(
			:company_name,
			:country_of_origin,
			:year_established,
			:company_size,
			:website,
			:facebook,
			:linkedin,
			:twitter,
			:instagram,
			:logo,
			:countries_where_exported,
			:brand_positioning,
			:social_causes,
			:social_organizations,
			:social_give_back,
			:active,
      address_attributes: [ 
        :address1,
        :address2,
        :city,
        :state,
        :postcode,
        :country
      ]
		)
	end
  def admin_brand_parameters
    params.require(:brand).permit(
			:company_name,
			:country_of_origin,
			:year_established,
			:company_size,
			:website,
			:facebook,
			:linkedin,
			:twitter,
			:instagram,
			:logo,
			:countries_where_exported,
			:brand_positioning,
			:social_causes,
			:social_organizations,
			:social_give_back,
			:subscriber,
			:active,
      address_attributes: [ 
        :address1,
        :address2,
        :city,
        :state,
        :postcode,
        :country
      ]
		)
	end	
	def check_usertype
		if @current_user.type? != "brand"
			redirect_to dashboard_url
		end
	end

end