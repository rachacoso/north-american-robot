class PasswordResetsController < ApplicationController
	skip_before_action :require_login

  def new
  	# render layout: "front"
  end

	def create
	  user = User.where(email: params[:email]).first
	  user.send_password_reset if user
	  redirect_to login_url, :notice => "AN EMAIL HAS BEEN SENT WITH PASSWORD RESET INSTRUCTIONS"
	end  

	def edit
	  @user = User.where(password_reset_token: params[:id]).first
	  # render layout: "front"
	end

	def update
	  @user = User.where(password_reset_token: params[:id]).first
	  if @user.password_reset_sent_at < 2.hours.ago
	    redirect_to new_password_reset_path, :alert => "PASSWORD RESET HAS EXPIRED"
	  elsif @user.update(password_update_parameters)
	    redirect_to login_url, :notice => "YOUR PASSWORD HAS BEEN RESET"
	  else
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
