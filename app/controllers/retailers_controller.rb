class RetailersController < ApplicationController

	before_action :check_usertype, only: [:edit, :public_profile, :full_profile, :update]

	def edit

    @retailer = @current_user.retailer

    @trade_shows = @retailer.trade_shows rescue nil
    @new_trade_show = TradeShow.new

    @countries_of_operation = @retailer.countries_of_operation rescue nil
    @new_country_of_operation = ExportCountry.new   

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

			redirect_to retailer_url


    else
      # not successful  
      # STILL INCOMPLETE NEED TO ADD VALIDATIONS
      flash[:error] = "Sorry, there were errors"

      redirect_to retailer_url, :flash => {
        :name_error => retailer.errors[:name].first
      }

    end


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
			:has_external_marketing,
			:where_product_advertised,
			:customer_database_size,
			:social_causes,
			:social_organizations,
			:social_give_back,
			:active,
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
  def admin_brand_parameters
    params.require(:retailer).permit(
			:company_name,
			:country_of_origin,
			:year_established,
			:company_size,
			:website,
			:facebook,
			:linkedin,
			:twitter,
			:instagram,
			:logo,
			:countries_where_exported,
			:brand_positioning,
			:social_causes,
			:social_organizations,
			:social_give_back,
			:subscriber,
			:active,
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
		if @current_user.type? != "retailer"
			redirect_to dashboard_url
		end
	end

end