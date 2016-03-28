class UsersController < ApplicationController

  skip_before_action :require_login, only: [:new, :create]

  #restrict to administrators only
  before_action :administrators_only, only: [:index, :edit, :update, :destroy]

  # persist the parameters on failed validation during new user signup
  before_action :persist_params, only: [:create]



  def new
    @newuser = User.new
    @newuser.build_contact    
  end

  def create

    @share_id = params[:pshare]

    @newuser = User.new

    @newuser.administrator = true if params[:administrator] #set as admin if admin create
    @newuser.email = params[:user][:email]
    @newuser.password = params[:user][:password]
    @newuser.password_confirmation = params[:user][:password_confirmation]
    @newuser.build_contact
    @newuser.contact.firstname = params[:user][:contact_attributes][:firstname]
    @newuser.contact.lastname = params[:user][:contact_attributes][:lastname]

    if verify_recaptcha(model: @newuser) && @newuser.save # if validates
      #create profile for the selected user type
      
      @newuser.initial_setup(params[:user_type])

      cookies[:auth_token] = @newuser.auth_token

      if params[:administrator]
        response_action = "redirect_to users_url"
      elsif params[:user_type] == 'distributor'
        response_action = "redirect_to distributor_url" # for regular logins
        @share_id ? (@redirect_url = view_match_url(@share_id, 'na')) : "" # for prospect share logins
      elsif params[:user_type] == 'brand'
        response_action = "redirect_to brand_url" # for regular logins
        @share_id ? (@redirect_url = view_match_url(@share_id, 'na')) : "" # for prospect share logins
      elsif params[:user_type] == 'retailer'
        response_action = "redirect_to retailer_url" # for regular logins
      else
        @share_id ? (@redirect_url = dashboard_url) : "" # for prospect share logins
        response_action = "redirect_to dashboard_url" # for regular logins
      end

    else
      render :new and return
    end

    respond_to do |format|
      format.html { eval(response_action) }
      format.js
    end

  end

# ADMIN ONLY

  def index
    # @users = User.all
    @distributors = User.all.reject{ |r| r.distributor.nil?}.reject{ |r| r.distributor.company_name.nil? }.sort_by{|i| i.distributor.company_name}
    @brands = User.all.reject{ |r| r.brand.nil? }.reject{ |r| r.brand.company_name.nil? }.sort_by{|i| i.brand.company_name}

    @admins = User.where(administrator: true)
    @users = User.where(:administrator.exists => false)

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

    # if params[:page_distributors]
    #   @distributors = do_kaminari_array(@distributors,params[:page_distributors])
    #   @active_section = 'distributors'
    # elsif params[:search_distributors]
    #   @distributors = User.where(email: /#{params[:search_distributors]}/i ).reject{ |r| r.distributor.nil?}.reject{ |r| r.distributor.company_name.nil? }.sort_by{|i| i.distributor.company_name}
    #   @distributors = do_kaminari_array(@distributors, 1)
    #   @active_section = 'distributors'
    # else
    #   @distributors = do_kaminari_array(@distributors, 1)
    # end

    # if params[:page_brands]
    #   @brands = do_kaminari_array(@brands, params[:page_brands])
    #   @active_section = 'brands'
    # elsif params[:search_brands]
    #   @brands = User.where(email: /#{params[:search_brands]}/i ).reject{ |r| r.brand.nil? }.reject{ |r| r.brand.company_name.nil? }.sort_by{|i| i.brand.company_name}
    #   @brands = do_kaminari_array(@brands, 1)
    #   @active_section = 'brands'      
    # else
    #   @brands = do_kaminari_array(@brands, 1)
    # end   

    if params[:page_users]
      @users = do_kaminari_array(@users, params[:page_users])
      @active_section = 'users'
    elsif params[:search_users]
      @users = User.where(email: /#{params[:search_users]}/i ).reject{ |r| r.administrator }
      @users = do_kaminari_array(@users, 1)
      @active_section = 'users'
      @active_search = 'true'
    else
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
      redirect_to :back
    end


  end

  def destroy
    user_to_nix = User.find(params[:id])
    user_to_nix.destroy
    redirect_to users_url, notice: "You have successfully deleted the user #{user_to_nix.email}."
  end




  private

  def user_parameters
    params.require(:user).permit(
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
  end

  def administrators_only
    unless @current_user.administrator
      redirect_to dashboard_url
    end
  end

  def do_kaminari_array(users, page)
    return Kaminari.paginate_array(users).page(page).per(20)
  end
end
