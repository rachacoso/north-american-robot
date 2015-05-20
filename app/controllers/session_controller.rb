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
		user = User.where(email: params[:email]).first
		if user && user.authenticate(params[:password])

	    if params[:keep_me_logged_in]
	      cookies.permanent[:auth_token] = user.auth_token
	    else
	      cookies[:auth_token] = user.auth_token  
	    end
			if user.administrator
				redirect_to admin_url
			else
				redirect_to '/dashboard'
			end
		else
			flash[:notice] = "INVALID EMAIL OR PASSWORD"
			redirect_to login_url
		end
	end

	def destroy
		# session[:user_id] = nil
		cookies.delete(:auth_token)
		redirect_to '/'
	end

end