class RetailersController < ApplicationController

	before_action :check_usertype, only: [:edit, :public_profile, :full_profile, :update]
  before_action :administrators_only, only: [:adminupdate]
  skip_before_action :require_login, only: [:view]

  # V2 ACTIONS
  def view

    @profile = Retailer.find(params[:id])

    unless @current_user
      session[:persisted_redirect] = view_retailer_url(@profile)
    end

    respond_to do |format|
      format.html
      format.js
    end

  end

  # ORIGINAL ACTIONS

	def edit

    @retailer = @current_user.retailer

    if @retailer.armor_account_id && @current_user.armor_user_id
      url = @retailer.api_get_bank_account_setup_url(armor_account_id: @retailer.armor_account_id, armor_user_id: @current_user.armor_user_id)
      unless @retailer.errors.any?
        @armor_bank_url = url
      end
    end

    @trade_shows = @retailer.trade_shows rescue nil
    @new_trade_show = TradeShow.new

		# for COUNTRIES OF OPERATION -- ODDLY NAMED SO CAN RE-USE EXISTING FORMS
    @countries_of_export = @retailer.countries_of_operation rescue nil
    @new_export_country = ExportCountry.new

    @tags = @retailer.tags rescue nil

	end

  def update

    retailer = @current_user.retailer

    # set general fields
    retailer.update(retailer_parameters)

    # set other fields

    # set year established
    if params[:year_established]
      retailer.update(year_established: Date.new(params[:year_established].to_i))
    end


    if params[:sectors]
			retailer.set_sectors(params[:sectors])
    end

    if params[:subsectors]
			retailer.set_subsectors(params[:subsectors])
    end

    if retailer.save
      # successful
      
      # update completeness
      # retailer.update_completeness

			if params[:redirect_anchor]
        redirect_to retailer_url + "#" + params[:redirect_anchor]
      else
				redirect_to retailer_url
			end


    else
      # not successful  
      # STILL INCOMPLETE NEED TO ADD VALIDATIONS
      flash[:error] = "Sorry, there were errors"

      redirect_to retailer_url, :flash => {
        :name_error => retailer.errors[:name].first
      }

    end


  end

  def validation_delete
    unless params[:type].blank?
      retailer = @current_user.retailer
      case params[:type]
      when 'bc' #business certificate
        retailer.verification_business_certificate.destroy
      when 'lp' #location photo
        retailer.verification_location_photo.destroy
      when 'bd' #brand display
        retailer.verification_brand_display_photo.destroy
      end
      retailer.save
    end
    redirect_to retailer_url + "#a-verification" 
  end

  def public_profile
    @profile = @current_user.retailer
  end

  def full_profile
    @profile = @current_user.retailer
  end

  def adminupdate
    retailer = Retailer.find(params[:id])
    retailer.update!(admin_retailer_parameters)
    redirect_to admin_retailer_view_url(retailer)
  end

  private
  def retailer_parameters
    params.require(:retailer).permit(
			:company_name,
			:country_of_origin,
			:year_established,
			:website,
			:company_size,
			:facebook,
			:linkedin,
			:twitter,
			:instagram,
			:logo,
			:countries_of_operation,
			:company_introduction,
			:number_of_locations,
			:number_of_brands_sold,
      :internal_marketing_size,
      :employ_pr_agency,
      :marketing_via_print,
      :marketing_via_online,
      :marketing_via_email,
      :marketing_via_outdoor,
      :marketing_via_events,
      :marketing_via_direct_mail,
      :marketing_via_email,
      :marketing_via_classes,
      :customer_database_size,
			:social_causes,
			:social_organizations,
			:social_give_back,
			:business_id,
      :verification_location_photo,
      :verification_brand_display_photo,
      :verification_business_certificate,
      :disable_armor_payments,
      address_attributes: [ 
        :address1,
        :address2,
        :city,
        :state,
        :postcode,
        :country
      ]
		)
	end
  def admin_retailer_parameters
    params.require(:retailer).permit(
			:logo,
      :verification_notes,
      :verified_website,
      :verified_social_media,
      :verified_business_registration,
      :verified_client_brand,
      :verified_business_certificate,
      :verified_location,
      :verified_brand_display,
			:subscriber,
			:active
		)
	end	
	def check_usertype
		if @current_user.type? != "retailer"
			redirect_to dashboard_url
		end
	end

end