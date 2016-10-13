class DistributorsController < ApplicationController

  before_action :check_usertype, only: [:edit, :public_profile, :full_profile, :update]
  before_action :administrators_only, only: [:adminupdate]
  skip_before_action :require_login, only: [:view]

  # V2 ACTIONS
  def view

    @profile = Distributor.find(params[:id])

    unless @current_user
      session[:persisted_redirect] = view_distributor_url(@profile)
    end

    respond_to do |format|
      format.html
      format.js
    end

  end

  # ORIGINAL ACTIONS

  def edit

    @distributor = @current_user.distributor

    if @distributor.armor_account_id && @distributor.users.with_armor_user_id.present?
      url = @distributor.api_get_bank_account_setup_url(armor_account_id: @distributor.armor_account_id, armor_user_id: @distributor.users.with_armor_user_id.first.armor_user_id)
      unless @distributor.errors.any?
        @armor_bank_url = url
      end
    end

    @current_brands = @distributor.distributor_brands.where(current: true) rescue nil
    @past_brands = @distributor.distributor_brands.where(current: false) rescue nil
    @new_brand = DistributorBrand.new

    @trade_shows = @distributor.trade_shows rescue nil
    @new_trade_show = TradeShow.new

    @channel_capacities = @distributor.channel_capacities
    @new_channel_capacity = ChannelCapacity.new

    @export_countries = @distributor.export_countries rescue nil
    @new_export_country = ExportCountry.new   

    @tags = @distributor.tags rescue nil

    # BUILD 'PRODUCT_TAGS' HASH WITH DISTRIBUTOR BRAND'S TAGS
    @product_tags = Hash.new
    @distributor.distributor_brands.each do |product|
      @product_tags[product.id] = product.tags
    end


  end

  def public_profile
    @profile = @current_user.distributor
  end

  def full_profile
    @profile = @current_user.distributor
  end

  def update

    @distributor = @current_user.distributor

    if params[:distributor][:us_shipping_terms] == "Other"
      other_terms = params[:distributor][:us_shipping_terms_other_comments]
      params[:distributor][:us_shipping_terms] = "Other - " + other_terms
    end

    # set general fields
    @distributor.update(distributor_parameters)

    # set other fields

    # set year established
    if params[:year_established]
      @distributor.update(year_established: Date.new(params[:year_established].to_i))
    end

    if params[:sectors]
      @distributor.set_sectors(params[:sectors])
    end

    if params[:subsectors]
      @sectors_set = @distributor.set_subsectors(params[:subsectors])
    end

    if params[:channels]
      # set channels
      assigned_channels = Channel.find(params[:channels].values) rescue []

      # delete channel capacities for disabled channels
      @distributor.channel_capacities.each do |cc|
        if !params[:channels].values.include?(cc.channel_id)
          cc.delete
        end
      end
      # initiate channel capacities for any new added
      assigned_channels.each do |ac|
        @distributor.channel_capacities.find_or_create_by(channel_id: ac.id)
      end

      unless assigned_channels.blank? 
        @distributor.channels = [] # clear current ones before update
      end
      assigned_channels.each do |s|
        @distributor.channels << s
      end
    end

    if params[:customchannels]

      params[:customchannels].each do |k,v|
        cname = v
        cchannel = @distributor.channel_capacities.find_or_create_by(custom_channel_name: cname, channel_id: 0)
        cchannel.save
      end

    end

    if params[:disable_armor_payments]
      @armor_payments = true
    end

    if params[:distributor][:payment_terms]
      @payment_terms_updated = @distributor.set_payment_terms(params[:distributor][:payment_terms])
    end

    if params[:distributor][:margin]
      @margin_updated = @distributor.set_margin(params[:distributor][:margin])
    end

    if @distributor.armor_account_id && @current_user.armor_user_id
      url = @distributor.api_get_bank_account_setup_url(armor_account_id: @distributor.armor_account_id, armor_user_id: @current_user.armor_user_id)
      unless @distributor.errors.any?
        @armor_bank_url = url
      end
    end

    if !@distributor.save
      flash.now[:error] = @distributor.errors.messages
    end

    respond_to do |format|
      format.html { 
        if @distributor.save
          # successful
          # update completeness
          @distributor.update_completeness
          # allow redirect via passed parameter only if in this array else redirect to the first onboard screen
          allowable_redirect = [
            'two',
            'three',
            'four',
            'complete'
          ]
          if params[:redirect]
            if allowable_redirect.include? params[:redirect]
              if params[:redirect] == 'complete'
                redirect_to dashboard_url
              else
                redir = "onboard_distributor_#{params[:redirect]}_url"
                redirect_to send(redir)
              end
              
            else
              redirect_to onboard_distributor_one_url
              # allow redirect via passed parameter only if in 'allowed' array, else redirect to the first onboard screen
            end
          elsif params[:redirect_anchor]
            redirect_to distributor_url + "#" + params[:redirect_anchor] 
          else
            redirect_to distributor_url
          end
        else
          # not successful  
          # STILL INCOMPLETE NEED TO ADD VALIDATIONS
          flash[:error] = "Sorry, there were errors"

          redirect_to distributor_url, :flash => {
            :name_error => @distributor.errors[:name].first
          }
        end
      } 
      format.js
    end
    
  end

  def adminupdate
    distributor = Distributor.find(params[:id])


    distributor.update!(admin_distributor_parameters)

    # update rating

    rating_items = [ 
      :verified_website,
      :verified_social_media,
      :verified_client_brand,
      :verified_business_registration,
      :verified_business_certificate,
      :verified_location,
      :verified_brand_display,
    ]

    new_rating = 0
    rating_items.each do |item|
      if distributor.send(item)
        new_rating += 1
      end
    end
    distributor.rating = new_rating
    distributor.save!   

    respond_to do |format|
      format.html { 
        redirect_to admin_distributor_view_url(distributor)
      }
      format.js 
    end
    
  end

  def validation_delete
    unless params[:type].blank?
      distributor = @current_user.distributor
      case params[:type]
      when 'bc' #business certificate
        distributor.verification_business_certificate.destroy
      when 'lp' #location photo
        distributor.verification_location_photo.destroy
      when 'bd' #brand display
        distributor.verification_brand_display_photo.destroy
      end
      distributor.save
    end
    redirect_to distributor_url + "#a-verification" 
  end

  private
  def distributor_parameters
    params.require(:distributor).permit(
      :company_name,
      :country_of_origin,
      :countries_of_distribution,
      :website,
      :facebook,
      :linkedin,
      :twitter,
      :instagram,
      :logo,
      :company_size,
      :company_introduction,
      :current_lines,
      :major_competitors,
      :social_causes,
      :social_organizations,
      :social_give_back,      
      :capacity_directly_operated_sites,
      :capacity_department_stores,
      :capacity_salons,
      :capacity_specialty_retailers,
      :capacity_home_shopping_networks,
      :capacity_online_malls,
      :capacity_social_commerce_sites,
      :outside_sales_size,
      :inside_sales_size,
      :sales_manager_name,
      :sales_manager_email,
      :education_manager_name,
      :education_manager_email,
      :education_provided_to,
      :sell_via_website,
      :sell_via_online_mall,
      :sell_via_social,
      :internal_marketing,
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
      :business_id,
      :verification_location_photo,
      :verification_brand_display_photo,
      :verification_business_certificate,
      :active,
      :disable_armor_payments,
      # :payment_terms,
      :us_shipping_terms,
      :accepts_overseas_shipment, 
      # :margin,
      :marketing_co_op,
      :damages_budget,
      :product_ticketing,
      :retailer_edi,
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

  def admin_distributor_parameters
    params.require(:distributor).permit(
      :company_name,
      :country_of_origin,
      :countries_of_distribution,
      :website,
      :facebook,
      :linkedin,
      :twitter,
      :instagram,
      :logo,
      :company_size,
      :company_introduction,
      :current_lines,
      :major_competitors,
      :social_causes,
      :social_organizations,
      :social_give_back,      
      :capacity_directly_operated_sites,
      :capacity_department_stores,
      :capacity_salons,
      :capacity_specialty_retailers,
      :capacity_home_shopping_networks,
      :capacity_online_malls,
      :capacity_social_commerce_sites,
      :outside_sales_size,
      :inside_sales_size,
      :sales_manager_name,
      :sales_manager_email,
      :education_manager_name,
      :education_manager_email,
      :education_provided_to,
      :sell_via_website,
      :sell_via_online_mall,
      :sell_via_social,
      :internal_marketing,
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
      :verification_location_photo,
      :verification_brand_display_photo,
      :verification_business_certificate,
      :verified_website,
      :verified_social_media,
      :verified_client_brand,
      :verified_business_registration,
      :verified_business_certificate,
      :verified_location,
      :verified_brand_display,
      :verification_notes,
      :subscriber,
      :active,
      :payment_terms_approved,
      :margin_approved,
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

  def check_usertype
    if @current_user.type? != "distributor"
      redirect_to dashboard_url
    end
  end

end