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
		@company = c
		redirect_to eval("#{u.company_type.downcase}_url") + "#a-armor"

	end


	def create_account
		u = @current_user
		if params[:armor_payments_terms]
			u.api_create_armor_payments_account
			if u.errors.any?
				flash[:error] = "Sorry, there was an error, please try again:"
				flash[:errorlist] = u.errors.full_messages
			end
		else
			flash[:error] = "Sorry, you must agree to Armor Payments Terms and Conditions"
		end

		redirect_to eval("#{u.company_type.downcase}_url") + "#a-armor"

	end




end