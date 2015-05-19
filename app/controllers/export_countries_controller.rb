class ExportCountriesController < ApplicationController

	def create

		u = @current_user.distributor || @current_user.brand

		if !params[:export_country][:country].empty?
			new_country = u.export_countries.find_or_initialize_by(country: params[:export_country][:country])
			if new_country.valid?
				u.save
			else
				new_country.destroy
			end
		end

		if @current_user.distributor
			u.update_completeness
		end 

		@export_countries = u.export_countries

	  respond_to do |format|
		  format.html
		  format.js
	  end

		# go_to_redirect

	end

	def update
		u = @current_user.distributor || @current_user.brand
		u.export_countries.find(params[:id]).update!(export_country_parameters)

		go_to_redirect

	end

	def destroy

		u = @current_user.distributor || @current_user.brand
		d = u.export_countries.find(params[:id])
		d.destroy
		@export_countries = u.export_countries rescue nil

		# update COMPLETENESS
		if @current_user.distributor
			u.update_completeness
		end

	  respond_to do |format|
		  format.html
		  format.js
	  end

		# go_to_redirect

	end


  private
  def export_country_parameters
    params.require(:export_country).permit(
			:country
		)
	end

	def go_to_redirect
		if @current_user.distributor
			if params[:ob] 
				redirect_to onboard_distributor_two_url
			else
				redirect_to distributor_url + "#" + "a-exportcountries" 
			end	
		else
			if params[:ob] 
				redirect_to onboard_brand_seven_url
			else
				redirect_to brand_url + "#" + "a-exportcountries" 
			end		
		end
	end

end