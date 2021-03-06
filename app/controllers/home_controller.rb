class HomeController < ApplicationController

	skip_before_action :require_login, only: [:front, :dashboard, :prospect_share, :prospect_share_login]
  	before_action only: [:dashboard] do
		check_subscription(area: 'restricted')
	end

	def front
		
		# for submenu
		@brand_chunk = Subsector.where(sector_id: Sector.where(name: 'Beauty / Personal Care').first.id).uniq { |p| p.name }.sort_by { |p| p.name }

		# for find links
		@trends = Trend.all.sort_by { |p| p.name }
		# @key_retailers = KeyRetailer.all.sort_by { |p| p.name }

		if @current_user
			if @current_user.administrator
				redirect_to admin_brands_index_url
			# else
			# 	redirect_to dashboard_url
			end
		else
			@newuser = User.new
			@newuser.build_contact
			render layout: "front"
		end
	end

	def login

	end

	def dashboard

		if @current_user

			@profile = @current_user.get_parent

			@current_orders = @profile.orders.current.count unless @current_user.brand
			@submitted_orders = @profile.orders.submitted.count
			@pending_orders = @profile.orders.pending.count
			@approved_orders = @profile.orders.approved.count
			@paid_orders = @profile.orders.paid.count
			@shipped_orders = @profile.orders.shipped.count
			@delivered_orders = @profile.orders.delivered.count
			@completed_orders = @profile.orders.completed.count
			@error_orders = @profile.orders.error.count
			@disputed_orders = @profile.orders.disputed.count
			# @active_orders = @profile.orders.active.count
			@active_orders = @current_user.brand ? @profile.orders.active_brand.count : @profile.orders.active.count

			@new_brands = Brand.activated.desc('c_at').limit(10)
			@updated_brands = Brand.activated.desc('u_at').limit(5)

			@recently_updated_orders = @profile.orders.active.desc('u_at').limit(10) if @current_user.brand

			products_with_photos = ProductPhoto.pluck(:photographable_id).uniq
			active_brands = Brand.activated.pluck(:id)
			@updated_products = Product.where(:brand_id.in => active_brands, :_id.in => products_with_photos).desc('u_at').desc('_id').limit(5)

			@adjustments = InventoryAdjustment.of_products(@profile.products.pluck(:id)).unfulfilled_requests if @current_user.brand
			# matches = @profile.matches
			# @unread_list = Array.new
			# matches.each do |m|
			# 	if m.messages.where(read: false, recipient: @current_user.type?).exists?
			# 		@unread_list << m
			# 	end
			# end
			# @incoming_requests_list = matches.where(accepted: false, initial_contact_by: @current_user.type_inverse?)
			# @outgoing_requests_list = matches.where(accepted: false, initial_contact_by: @current_user.type?)


			# case @current_user.type?
			# when "distributor"
			# 	@sector = @profile.sector_ids.to_s
		 #  	@gallery = ProductPhoto.where(photographable_type: "Product").shuffle[0..4]
			# 	@gallery_products = ProductPhoto.where(photographable_type: "Product").shuffle[0..11]

			# when "brand"

			# 	@all_matches = Distributor.in(sector_ids: @profile.sector_ids).excludes(country_of_origin: "", export_countries: nil)
			# 	@countries_of_distribution = Array.new
			# 	@all_matches.each do |m|
			# 		if !m.export_countries.blank?
			# 			@countries_of_distribution = (@countries_of_distribution << m.export_countries.pluck(:country)).flatten!
			# 		end
			# 	end
			# 	@country_of_distribution = @countries_of_distribution.uniq!
				
			# end
		end
		
	end

	def prospect_share
		if @share_id = params[:id]
			if @current_user
				if @current_user.brand
					# currently can only share brands, so only visible by distributors
					redirect_to dashboard_url and return
				elsif @current_user.distributor
					redirect_to view_match_url(@share_id, 'na') and return
				elsif @current_user.administrator
					redirect_to admin_brand_view_url(@share_id) and return
				end
			end
		else
			redirect_to root and return
		end
		render layout: "front"
	end

	def prospect_share_login

		unless params[:email].empty?
			if (@share_id = params[:share_id]) && (@email = params[:email])
				if User.where(email: @email).exists?
					@has_a_login = true
				else
			    @newuser = User.new
			    @newuser.build_contact 
				end
			else
				redirect_to root
			end
		end

		respond_to do |format|
			format.html
			format.js
		end 

	end


	private

	def is_a_brand?
		return true if @current_user && @current_user.brand
	end
end