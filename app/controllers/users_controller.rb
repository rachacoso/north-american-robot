class UsersController < ApplicationController

  skip_before_action :require_login, only: [:new, :create, :confirm_email]

  #restrict to administrators only
  before_action :administrators_only, only: [:index, :edit, :update, :destroy, :admin_index]

  # persist the parameters on failed validation during new user signup
  before_action :persist_params, only: [:create]



  def new
    @newuser = User.new
    @newuser.build_contact
    if ["brand", "retailer", "distributor"].include? params[:t]
      type = params[:t]
    end
    respond_to do |format|
      format.html {
        if type
          render "new_#{type}"
        else
          redirect_to root_url
        end
      }
      format.js
    end
  end

  def create

    @newuser = User.new
    @newuser.build_contact

    if all_user_params_present

      @newuser.administrator = true if params[:administrator] #set as admin if admin create

      @newuser.email = @user_email
      @newuser.password = params[:user][:password]
      @newuser.password_confirmation = params[:user][:password_confirmation]
      @newuser.contact.firstname = @user_firstname
      @newuser.contact.lastname = @user_lastname

      if verify_recaptcha(model: @newuser) && @newuser.save # if validates
      # if @newuser.save # if validates
        #create profile for the selected user type
        @newuser.initial_setup(type: @user_type, company_name: @company_name, website: @website)

        # no longer log in automatically, need to confirm email (except if administrator)
        if params[:administrator]
          cookies[:auth_token] = @newuser.auth_token
        end

        # for new user modal firing
        flash[:newuser_confirmation_needed] = "#{@newuser.email}"

        if params[:administrator]
          @redirect_url = users_url
        else
          @redirect_url = login_url
        end

      end
    
    end

    respond_to do |format|
      format.html { redirect_to @redirect_url }
      format.js
    end

  end

  def limited_update #allow user to update phone (fun hack needed for Armor Payments signup)
    if user = User.find(params[:id])
      user.update(user_limited_update_parameters)
      if user.save
        @notice = DateTime.now.strftime("UPDATED at %I:%M%p")
      else
        @notice = "Sorry, There were errors"
        @errors = user.errors
      end
    end
    respond_to do |format|
      format.html { redirect_to eval("#{user.company_type.downcase}_url") + "#a-logins" }
      format.js
    end
  end

  def confirm_email
    user = User.find_by(email_confirmation_token: params[:token])
    if user
      user.confirm_email
      flash[:email_confirmed] = user.email
      redirect_to login_url
    else
      flash[:email_confirmation_failed] = true
      redirect_to login_url
    end
  end

# ADMIN ONLY

  def index
    # @users = User.all
    @distributors = User.all.reject{ |r| r.distributor.nil?}.reject{ |r| r.distributor.company_name.nil? }.sort_by{|i| i.distributor.company_name}
    @brands = User.all.reject{ |r| r.brand.nil? }.reject{ |r| r.brand.company_name.nil? }.sort_by{|i| i.brand.company_name}

    @admins = User.where(administrator: true)
    @users = User.where(:administrator.exists => false).order_by(:email.asc)

    @newuser = User.new
    @newuser.build_contact

    if params[:page_admins]
      @admins = @admins.page(params[:page_admins]).per(20)
      @active_section = 'admins'
    elsif params[:search_admins]
      @admins = @admins.any_of({firstname: /#{params[:search_admins]}/i}, {lastname: /#{params[:search_admins]}/i}, {lastname: /#{params[:email]}/i} )
    else
      @admins = @admins.page(1).per(20)
    end   

    if params[:page_users]
      @active_section = 'users'
      if params[:search_users]
        @users = User.where(email: /#{params[:search_users]}/i ).reject{ |r| r.administrator }
        @active_search = 'true'
      end  
      @users = do_kaminari_array(@users, params[:page_users])
      # @users = do_kaminari_array(@users, 1)
    else
      if params[:search_users]
        @users = User.where(email: /#{params[:search_users]}/i ).reject{ |r| r.administrator }
      end
      @users = do_kaminari_array(@users, 1)
    end  

  end

  def admin_index
    # @users = User.all
    @distributors = User.all.reject{ |r| r.distributor.nil?}.reject{ |r| r.distributor.company_name.nil? }.sort_by{|i| i.distributor.company_name}
    @brands = User.all.reject{ |r| r.brand.nil? }.reject{ |r| r.brand.company_name.nil? }.sort_by{|i| i.brand.company_name}

    @admins = User.where(administrator: true)
    @users = User.where(:administrator.exists => false).order_by(:email.asc)

    @newuser = User.new
    @newuser.build_contact

    if params[:page_admins]
      @admins = @admins.page(params[:page_admins]).per(20)
      @active_section = 'admins'
    elsif params[:search_admins]
      @admins = @admins.any_of({firstname: /#{params[:search_admins]}/i}, {lastname: /#{params[:search_admins]}/i}, {lastname: /#{params[:email]}/i} )
    else
      @admins = @admins.page(1).per(20)
    end   

    if params[:page_users]
      @active_section = 'users'
      if params[:search_users]
        @users = User.where(email: /#{params[:search_users]}/i ).reject{ |r| r.administrator }
        @active_search = 'true'
      end  
      @users = do_kaminari_array(@users, params[:page_users])
      # @users = do_kaminari_array(@users, 1)
    else
      if params[:search_users]
        @users = User.where(email: /#{params[:search_users]}/i ).reject{ |r| r.administrator }
      end
      @users = do_kaminari_array(@users, 1)
    end  

  end


  def edit
    @user = User.find(params[:id])
  end

  def update

    @user = User.find(params[:id])    

    case params[:update_type]
    when 'email'
      if params[:user][:email].blank?
        flash.now[:notice] = "Email field cannot be blank"
        @newuser = User.new
        render :edit
      elsif @user.email == params[:user][:email]
        @newuser = User.new
        render :edit
      elsif User.where(email: params[:user][:email]).exists?
        flash.now[:notice] = "Someone else is already using that email address"
        render :edit
      else
        flash.now[:notice] = "Email has been changed from #{@user.email} to #{params[:user][:email]}"
        @user.email = params[:user][:email]
        @user.save!
        redirect_to :back
      end

    when 'password'

      if params[:user][:new_password].blank? || params[:user][:new_password_confirmation].blank?
        flash.now[:notice] = "Password fields cannot be blank"
        @newuser = User.new
        render :edit
      elsif params[:user][:new_password] != params[:user][:new_password_confirmation]
        flash.now[:notice] = "Passwords must match"
        @newuser = User.new
        render :edit        
      else
        @user.password = params[:user][:new_password]
        @user.password_confirmation = params[:user][:new_password_confirmation]
        flash[:notice] = "Password has been changed"
        @user.save!
        redirect_to :back
      end
    when 'admin'
      user = User.find(params[:id])
      user.update(user_parameters)
      user.save!
      respond_to do |format|
        format.html {redirect_to :back}
        format.js
      end
    end


  end

  def destroy
    user_to_nix = User.find(params[:id])
    user_to_nix.destroy
    redirect_to users_url, notice: "You have successfully deleted the user #{user_to_nix.email}."
  end




  private

  def user_limited_update_parameters
    params.require(:user).permit(
      contact_attributes: [
        :firstname,
        :lastname,
        :title,
        :phone
      ]
    )
  end 

  def user_parameters
    params.require(:user).permit(
      :can_submit_under_minimum,
      contact_attributes: [
        :firstname,
        :lastname,
        :title,
        :email,
        :phone,
        address_attributes: [
          :address1,
          :address2,
          :city,
          :state,
          :postcode,
          :country
        ]
      ],
      brand_attributes: [ 
        :subscriber
      ],
      distributor_attributes: [ 
        :subscriber
      ]

    )
  end 

  def persist_params
    if params[:user][:email]
      @user_email = params[:user][:email]
    end
    if params[:user][:contact_attributes][:firstname]
      @user_firstname = params[:user][:contact_attributes][:firstname]
    end
    if params[:user][:contact_attributes][:lastname]
      @user_lastname = params[:user][:contact_attributes][:lastname]
    end
    if params[:user_type]
      @user_type = params[:user_type]
    end
    if @user_type == "brand"
      if params[:user][:brand][:company_name]
        @company_name = params[:user][:brand][:company_name]
      end
      if params[:user][:brand][:website]
        @website = params[:user][:brand][:website]
      end
    end
  end

  def administrators_only
    unless @current_user.administrator
      redirect_to dashboard_url
    end
  end

  def do_kaminari_array(users, page)
    return Kaminari.paginate_array(users).page(page).per(20)
  end

  private

  def all_user_params_present
    if @user_type == "brand"
      @newuser.errors.add("company_name","can't be blank") if params[:user][:brand][:company_name].blank?
      @newuser.errors.add("website","can't be blank") if params[:user][:brand][:website].blank?
    end
    @newuser.errors.add("email","can't be blank") if params[:user][:email].blank?
    @newuser.errors.add("email","should be a proper email address") unless params[:user][:email].match(/.+@.+/)
    @newuser.errors.add("password","can't be blank") if params[:user][:password].blank?
    @newuser.errors.add("password_confirmation","must match password") if params[:user][:password] != params[:user][:password_confirmation]
    if @newuser.errors.any?
      return false
    else
      return true
    end
  end

end
