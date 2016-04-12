class ArmorPaymentsController < ApplicationController

	def complete_required
		u = @current_user
		c = @current_user.company

		# Company Info Items
		c.company_name = params[:company_name] if params[:company_name]
		c.address.address1 = params[:address1] if params[:address1]
		c.address.address2 = params[:address2] if params[:address2]
		c.address.city = params[:city] if params[:city]
		c.address.state = params[:state] if params[:state]
		c.address.postcode = params[:postcode] if params[:postcode]
		c.address.country = params[:country] if params[:country]
		c.save

		# User Login Items
		u.contact.firstname = params[:user_firstname] if params[:user_firstname]
		u.contact.lastname = params[:user_lastname] if params[:user_lastname]
		u.contact.phone = params[:user_phone] if params[:user_phone]
		unless u.save # currently only user.contact.phone validated
			flash[:error] = "last phone number entered was invalid"
		end

		redirect_to eval("#{u.company_type.downcase}_url") + "#a-armor"

	end

end