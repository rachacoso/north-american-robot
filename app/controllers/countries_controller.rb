class CountriesController < ApplicationController
  
	def create
		newcountry = Country.new
		newcountry.name = params[:country][:name]
		newcountry.shortcode = params[:country][:shortcode]

		if newcountry.valid?
			newcountry.save!
			redirect_to admin_url
		else
			redirect_to admin_url, :flash => { :country_error => newcountry.errors.messages } # error name is the downcase of model class name
		end

	end

	def destroy
		country = Country.find(params[:id])
		country.destroy
		redirect_to admin_url

	end

	def update

	end


end