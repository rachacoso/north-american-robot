class PasswordResetsController < ApplicationController
	skip_before_action :require_login

  def new
  	# render layout: "front"
  end

	def create
	  user = User.where(email: params[:email]).first
	  share_id = params[:pshare]
	  user.send_password_reset(share_id) if user
	  unless share_id
		  redirect_to login_url, :notice => "AN EMAIL HAS BEEN SENT WITH PASSWORD RESET INSTRUCTIONS" and return
		end

		respond_to do |format|
			format.html
			format.js
		end 
				
	end  

	def edit
	  @user = User.where(password_reset_token: params[:id]).first
	  @share_id = params[:pshare]
	  # render layout: "front"
	end

	def update
	  @user = User.where(password_reset_token: params[:id]).first
	  if @user.password_reset_sent_at < 2.hours.ago
	  	if params[:pshare]
	  		redirect_to prospect_share_path(params[:pshare]), :alert => "PASSWORD SET/RESET HAS EXPIRED"
	  	else
		    redirect_to new_password_reset_path, :alert => "PASSWORD SET/RESET HAS EXPIRED"
		  end
	  elsif @user.update(password_update_parameters)
	  	if params[:pshare]
	  		redirect_to prospect_share_path(params[:pshare]), :notice => "YOUR PASSWORD HAS BEEN RESET"
	  	else
		    redirect_to login_url, :notice => "YOUR PASSWORD HAS BEEN RESET"
		  end
	  else
	  	@share_id = params[:pshare]
	    render :edit
	  end
	  # render layout: "front"
	end

	private

	def password_update_parameters
		params.require(:user).permit(
				:password,
				:password_confirmation
			)
	end
	

end
