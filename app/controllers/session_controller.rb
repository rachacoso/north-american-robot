class SessionController < ApplicationController
	
	skip_before_action :require_login, only: [:new, :create]

	def new
		if @current_user
			redirect_to root_url and return
		else
			@newuser = User.new
			@newuser.build_contact
		end

    respond_to do |format|
      format.html { render layout: "front" }
      format.js
    end
	end

	def create
		@user = User.find_by(email: params[:email])
		@share_id = params[:share_id]


		if @user && @user.authenticate(params[:password])
			if params[:keep_me_logged_in]
				cookies.permanent[:auth_token] = @user.auth_token
			else
				cookies[:auth_token] = @user.auth_token  
			end
			if @user.administrator
				redirect_url = admin_brands_index_url
			else
				if @share_id #is login from a share link
					if @user.brand
						# currently can only share brands, so only visible by distributors
						redirect_url = dashboard_url
					elsif @user.distributor
						redirect_url = view_match_url(@share_id, 'na')
					end
				elsif session[:persisted_redirect] && @user.type? != 'brand' # if a persisted redirect exists and user isn't a brand
					redirect_url = session[:persisted_redirect]
					session[:persisted_redirect] = nil # reset the redirect
					flash[:newuser] = true if @user.last_login.blank? # is a new user (i.e. has never logged in)
				elsif @user.last_login.blank? # is a new user (i.e. has never logged in)
					redirect_url = eval("#{@user.type?}_url")
					flash[:newuser] = true
				else
					redirect_url = dashboard_url
				end
			end
		else
			flash[:notice] = "INVALID EMAIL or PASSWORD"
			if @share_id #is login from a share link
				redirect_url = prospect_share_url(@share_id)
			else
				redirect_url = login_url
			end
		end


    respond_to do |format|
      format.html { redirect_to redirect_url }
      format.js
    end

	end

	def destroy
		# session[:user_id] = nil
		cookies.delete(:auth_token)
		redirect_to root_url
	end

end