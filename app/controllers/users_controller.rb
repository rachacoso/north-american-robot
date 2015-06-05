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

    if User.where(email: params[:user][:email]).exists?

      flash[:error] = "That email address is already in use"
      @newuser = User.new
      @newuser.build_contact
      redirection

    elsif params[:user][:email].blank?

      flash[:error] = "Email field cannot be blank"
      persist_params
      @newuser = User.new
      @newuser.build_contact
      redirection


    elsif params[:user][:contact_attributes][:firstname].blank? || params[:user][:contact_attributes][:lastname].blank?

      flash[:error] = "Please enter a first and last name"
      @newuser = User.new
      @newuser.build_contact
      redirection

    elsif params[:user][:password].blank? || params[:user][:password_confirmation].blank?

      flash[:error] = "Password fields cannot be blank"
      @newuser = User.new
      @newuser.build_contact
      redirection

    elsif params[:user][:password] != params[:user][:password_confirmation]

      flash[:error] = "Passwords did not match"
      @newuser = User.new
      @newuser.build_contact
      redirection

    else

      if params[:administrator] #create ADMIN user
        user = User.new

        user.build_contact
        user.email = params[:user][:email]
        user.password = params[:user][:password]
        user.password_confirmation = params[:user][:password_confirmation]
        user.contact.firstname = params[:user][:contact_attributes][:firstname]
        user.contact.lastname = params[:user][:contact_attributes][:lastname]
        user.administrator = true
        user.save!
        redirect_to users_url

      else 

        user = User.new
        
        user.build_contact
        user.email = params[:user][:email]
        user.password = params[:user][:password]
        user.password_confirmation = params[:user][:password_confirmation]
        user.contact.firstname = params[:user][:contact_attributes][:firstname]
        user.contact.lastname = params[:user][:contact_attributes][:lastname]
        # user.save!
        
        #create profile for the selected user type
        if params[:user_type] == 'distributor' || params[:user_type] == 'brand' # restrict to only allowed values
          createusertype = "create_" + params[:user_type]
          user.send(createusertype) # create relation
   
          # prepopulate contact info with user info (user can change later)
          brand_or_distributor = user.send(params[:user_type])
          brand_or_distributor.create_address
          brand_or_distributor.contacts << Contact.new(
            firstname: params[:user][:contact_attributes][:firstname], 
            lastname: params[:user][:contact_attributes][:lastname], 
            email: params[:user][:email])          
          user.save!

        end

        cookies[:auth_token] = user.auth_token

        if params[:user_type] == 'distributor'
          redirect_to distributor_url
        elsif params[:user_type] == 'brand'
          redirect_to brand_url
        else
          redirect_to dashboard_url
        end

      end

    end    
  end

# ADMIN ONLY

  def index
    # @users = User.all
    @distributors = User.all.reject{ |r| r.distributor.nil?}.reject{ |r| r.distributor.company_name.nil? }.sort_by{|i| i.distributor.company_name}
    @brands = User.all.reject{ |r| r.brand.nil? }.reject{ |r| r.brand.company_name.nil? }.sort_by{|i| i.brand.company_name}

    @admins = User.where(administrator: true)

    @newuser = User.new
    @newuser.build_contact

    if params[:page_admins]
      @admins = @admins.page(params[:page_admins]).per(20)
    else
      @admins = @admins.page(1).per(20)
    end   

    if params[:page_distributors]
      @distributors = Kaminari.paginate_array(@distributors).page(params[:page_distributors]).per(20)
    else
      @distributors = Kaminari.paginate_array(@distributors).page(1).per(20)
    end

    if params[:page_brands]
      @brands = Kaminari.paginate_array(@brands).page(params[:page_brands]).per(20)
    else
      @brands = Kaminari.paginate_array(@brands).page(1).per(20)
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
        redirect_to users_path
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
        flash.now[:notice] = "You have changed your password"
        @user.save!
        redirect_to users_path
      end

    when 'logo'
      profile = @user.brand || @user.distributor
      logofile = params[:user]["#{@user.type?}_attributes".to_sym][:logo]
      profile.logo = logofile
      profile.save
      redirect_to :back     
    when 'adminsubscriber'
      user = User.find(params[:id])
      user.update(user_parameters)
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
      brand_attributes: [ 
        :subscriber
      ],
      distributor_attributes: [ 
        :subscriber
      ]

    )
  end 

  def redirection 
    if params[:administrator]
      redirect_to users_url
    else
      # redirect_to root_url
      # render 'home/front'
      render 'users/new'
    end
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

end
