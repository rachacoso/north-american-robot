class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :get_current_user
  before_action :require_login
  before_action :get_display
  before_action :get_unread_message_count
  before_action :administrator_redirect

	private
  def get_current_user
  	if cookies[:auth_token]
      if a = User.where(:auth_token => cookies[:auth_token]).first
    		@current_user = a
         # update last login (if hasn't been updated in the last hour)
        unless (1.hours.ago..DateTime.now).cover?(a.last_login)
          a.last_login = DateTime.now
          a.save!
        end
      else
       cookies.delete :auth_token
       @current_user = nil
       flash[:notice] = "YOU MUST BE LOGGED IN TO ACCESS11"
       redirect_to login_url # halts request cycle       
      end
    end
  end
 
  def require_login
    unless @current_user
      flash[:notice] = "YOU MUST BE LOGGED IN TO ACCESS22"
      redirect_to login_url # halts request cycle
    end
  end

  def get_display
    
      @display = Display.all.first rescue nil
    
  end

  def get_unread_message_count
    if @current_user
      u = @current_user.distributor || @current_user.brand
      m = u.matches rescue nil
      if m
        match_ids = m.pluck(:id)
        @messages_unread = Message.in(match_id: match_ids).where(read: false, recipient: @current_user.type?).count
        @new_contact_messages = m.where(accepted: false, initial_contact_by: @current_user.type_inverse?).count
      end
    end
  end

  def administrator_redirect
    if @current_user && @current_user.administrator
      unless controller_name == "users" || controller_name == "admin" || controller_name == "session" || controller_name == "sectors" || controller_name == "channels" || controller_name = "comapny_sizes" || controller_name = "displays" 
        redirect_to admin_url
      end
    end
  end

end
