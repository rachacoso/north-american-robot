class BrandsController < ApplicationController

	before_action :check_usertype, only: [:edit, :public_profile, :full_profile, :update]
	skip_before_action :require_login, only: [:index]

	def index

		@sectors = Sector.all
		@brands = Brand.activated

		@brand_tags = Tag.where(taggable_type: "Brand").uniq { |p| p.name }.sort_by { |p| p.name }
		# drop if no active brands use tag
		@brand_tags.reject! { |bt| Brand.activated.find(bt.taggable_id).blank? }

		@product_tags = Tag.where(taggable_type: "Product").uniq { |p| p.name }

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