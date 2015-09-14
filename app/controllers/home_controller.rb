class HomeController < ApplicationController
  
  skip_before_action :require_login, only: [:front, :prospect_share, :prospect_share_login]

	def front
		if @current_user
			if @current_user.administrator
				redirect_to admin_url
			else
				redirect_to dashboard_url
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
		@profile = @current_user.brand || @current_user.distributor

		matches = @profile.matches
		@unread_list = Array.new
		matches.each do |m|
			if m.messages.where(read: false, recipient: @current_user.type?).exists?
				@unread_list << m
			end
		end

		@incoming_requests_list = matches.where(accepted: false, initial_contact_by: @current_user.type_inverse?)
		@outgoing_requests_list = matches.where(accepted: false, initial_contact_by: @current_user.type?)


		case @current_user.type?
		when "distributor"
			@sector = @profile.sector_ids.to_s
	  	@gallery = ProductPhoto.where(photographable_type: "Product").shuffle[0..4]
		when "brand"

			@all_matches = Distributor.in(sector_ids: @profile.sector_ids).excludes(country_of_origin: "", export_countries: nil)
			@countries_of_distribution = Array.new
			@all_matches.each do |m|
				if !m.export_countries.blank?
					@countries_of_distribution = (@countries_of_distribution << m.export_countries.pluck(:country)).flatten!
				end
			end
			@country_of_distribution = @countries_of_distribution.uniq!
			
		end

	end

	def prospect_share
		if @share_id = params[:id]
			if @current_user
				if @current_user.brand
					# currently can only share brands, so only visible by distributors
					redirect_to dashboard_url
				elsif @current_user.distributor
					redirect_to view_match_url(@share_id, 'na')
				elsif @current_user.administrator
					redirect_to admin_brand_view_url(@share_id)
				end
			elsif params[:prospect_email]
				@prospect_email = params[:prospect_email]
			end
		else
			redirect_to root
		end
		render layout: "front"
	end

	def prospect_share_login
		if params[:return] == "true"
			@return = true
		elsif @share_id = params[:share_id] && @email = params[:email]
			if User.where(email: @email).exists?
				@has_a_login = true
			else

			end
		else
			redirect_to root
		end

		respond_to do |format|
			format.html
			format.js
		end 

	end

end