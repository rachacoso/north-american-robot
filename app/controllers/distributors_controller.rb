class DistributorsController < ApplicationController

  before_action do
    check_usertype("distributor")
  end  

  def edit

    @distributor = @current_user.distributor

    @current_brands = @distributor.distributor_brands.where(current: true) rescue nil
    @past_brands = @distributor.distributor_brands.where(current: false) rescue nil
    @new_brand = DistributorBrand.new

    @trade_shows = @distributor.trade_shows rescue nil
    @new_trade_show = TradeShow.new

    @channel_capacities = @distributor.channel_capacities
    @new_channel_capacity = ChannelCapacity.new

    @export_countries = @distributor.export_countries rescue nil
    @new_export_country = ExportCountry.new   

  end

  def public_profile
    @profile = @current_user.distributor
  end

  def full_profile
    @profile = @current_user.distributor
  end

  def update

    distributor = @current_user.distributor


    # set general fields
    distributor.update(distributor_parameters)

    # set other fields

    # set year established
    if params[:year_established]
      distributor.update(year_established: Date.new(params[:year_established].to_i))
    end

    if params[:sectors]
      # set sectors
      assigned_sectors = Sector.find(params[:sectors].values) rescue []
      unless assigned_sectors.blank?
        distributor.sectors = [] # clear current ones before update
      end
      assigned_sectors.each do |s|
        distributor.sectors << s
      end
    end

    if params[:channels]
      # set channels
      assigned_channels = Channel.find(params[:channels].values) rescue []

      # delete channel capacities for disabled channels
      distributor.channel_capacities.each do |cc|
        if !params[:channels].values.include?(cc.channel_id)
          cc.delete
        end
      end
      # initiate channel capacities for any new added
      assigned_channels.each do |ac|
        distributor.channel_capacities.find_or_create_by(channel_id: ac.id)
      end

      unless assigned_channels.blank? 
        distributor.channels = [] # clear current ones before update
      end
      assigned_channels.each do |s|
        distributor.channels << s
      end
    end

    if params[:customchannels]

      params[:customchannels].each do |k,v|
        cname = v
        cchannel = distributor.channel_capacities.find_or_create_by(custom_channel_name: cname, channel_id: 0)
        cchannel.save
      end

    end

    if distributor.save
      # successful
      
      # update completeness
      distributor.update_completeness

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
        :name_error => distributor.errors[:name].first
      }

    end


  end

  def validationupdate
    distributor = Distributor.find(params[:id])


    distributor.update!(distributor_parameters)

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

    redirect_to edit_user_url(distributor.user)

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
      :logo,
      :company_size,
      :current_lines,
      :major_competitors,
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
      contact_info_attributes: [ 
        :contact_name,
        :contact_title,
        :email,
        :phone,
        :address1,
        :address2,
        :city,
        :state,
        :postcode,
        :country
      ]
    )
  end
  def check_usertype(type)
    if @current_user.type? != type
      redirect_to dashboard_url
    end
  end

end