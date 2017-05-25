class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :get_current_user
  before_action :require_login
  before_action :get_display
  before_action :get_unread_message_count
  before_action :administrator_redirect
  before_action do
    check_subscription(area: 'public')
  end

  # DATE SAVING (used for collections date [trade show, trademarks, patents, compliances])
  def save_date(year, month, item)
    unless year.empty? && month.empty?
      item.date = Date.strptime("#{month}-#{year}", '%m-%Y')
      item.save
    end 
  end



	private

  def administrators_only
    unless @current_user.administrator
      redirect_to root_url
    end
  end
    
  def get_current_user
  	if cookies[:auth_token]
      if a = User.find_by(auth_token: cookies[:auth_token])
        if a.email_confirmed # check to see if email has been confirmed
      		@current_user = a
           # update last login (if hasn't been updated in the last hour)
          unless (1.hours.ago..DateTime.now).cover?(a.last_login)
            now = DateTime.now
            a.last_login = now
            a.save!
            unless a.administrator
              b_or_d = a.send(a.type?)
              b_or_d.last_login = now
              b_or_d.save!
            end
          end
        else # re/send email confirmation if email not yet confirmed and logout
          a.resend_confirmation
          cookies.delete :auth_token
          flash[:newuser_confirmation_needed] = "#{a.email}"
          flash[:newuser_returning] = true
          @current_user = nil
          redirect_to login_url and return # halts request cycle     
        end
      else
        cookies.delete :auth_token
        @current_user = nil
        flash[:notice] = "YOU MUST BE LOGGED IN TO ACCESS (err: 11)"
        redirect_to login_url # halts request cycle       
      end
    end
  end
 
  def require_login
    unless @current_user 
      flash[:notice] = "YOU MUST BE LOGGED IN TO ACCESS (err: 22)"
      session[:persisted_redirect] = nil # reset any persisted redirect
      redirect_to login_url # halts request cycle
    end
  end

  def get_display
    
      @display = Display.all.first rescue nil
    
  end

  def get_unread_message_count
    if @current_user
      u = @current_user.distributor || @current_user.brand || @current_user.retailer
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

  def check_subscription(area:)
    if @current_user && @current_user.brand #checks for brand approval & subscription
      if @current_user.brand.subscriber_account_number.blank? #set account number for any legacy brands who don't have acct number
        @current_user.brand.set_subscriber_account_number
        @current_user.brand.save
      end
      case area
      when "restricted"
          if !@current_user.brand.active
            render "/pages/private/wait"
          elsif !@current_user.brand.subscriber?
            render "/pages/private/subscribe"
          end
      when "public"
          if !@current_user.brand.active
            @brand_subscriber_status = "not approved"
          elsif !@current_user.brand.subscriber?
            @brand_subscriber_status = "not subscribed"
          end
      end
    end
  end

end
