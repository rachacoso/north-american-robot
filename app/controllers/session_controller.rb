class SessionController < ApplicationController
	
	skip_before_action :require_login, only: [:new, :create]

	def new
		if @current_user
			redirect_to dashboard_url
		else
			@newuser = User.new
			@newuser.build_contact
			render layout: "front"
		end
	end

	def create
		@user = User.where(email: params[:email]).first
		@share_id = params[:share_id]

		if @share_id #is login from a share link

			if @user && @user.authenticate(params[:password])
				if params[:keep_me_logged_in]
					cookies.permanent[:auth_token] = @user.auth_token
				else
					cookies[:auth_token] = @user.auth_token  
				end
				if @user.administrator
					@redirect_url = admin_brands_index_url
				else
					if @user.brand
						# currently can only share brands, so only visible by distributors
						@redirect_url = dashboard_url
					elsif @user.distributor
						@redirect_url = view_match_url(@share_id, 'na')
					end
				end
			else
				flash.now[:notice] = "INVALID PASSWORD"
				@redirect_url = prospect_share_url(@share_id)
			end

		else #is regular login

			if @user && @user.authenticate(params[:password])
				if params[:keep_me_logged_in]
					cookies.permanent[:auth_token] = @user.auth_token
				else
					cookies[:auth_token] = @user.auth_token  
				end
				if @user.administrator
					@redirect_url = admin_brands_index_url
				else
					@redirect_url = root_url
				end
			else
				flash[:notice] = "INVALID EMAIL OR PASSWORD"
				@redirect_url = login_url
			end

		end

    respond_to do |format|
      format.html { redirect_to @redirect_url }
      format.js
    end

	end

	def destroy
		# session[:user_id] = nil
		cookies.delete(:auth_token)
		redirect_to '/'
	end

end