class ArmorPaymentsController < ApplicationController

	skip_before_action  :verify_authenticity_token, :get_current_user, :require_login, only: [:webhook]

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
			else
				flash[:error] = nil
				flash[:errorlist] = nil
				flash[:newaccount] = true
			end
		else
			flash[:error] = "Sorry, you must agree to Armor Payments Terms and Conditions"
		end

    respond_to do |format|
      format.html { redirect_to eval("#{u.company_type.downcase}_url") + "#a-armor" } 
      format.js
    end

	end


	def webhook
		if params[:event].present?
			event_type = params[:event][:type].to_i
			order_event_types = *(0..30) # order events 
			account_event_types = [1000,1001] # account events 

			if order_event_types.include? event_type # get order if order type event
				get_order(params[:event][:order_id])
				if @order.blank?
					render :nothing => true
					return
				end
			elsif account_event_types.include? event_type # get company if account type event
				get_company(params[:event][:account_id])
				if @company.blank?
					render :nothing => true
					return
				end
			end

			case event_type
			when 0
				logger.info "Armor Webhook Event ID 0 (order create): #{@order.id}"
			when 1
				logger.info "Armor Webhook Event ID 1 (order sent): #{@order.id}"
			when 2
				@order.paid
			when 3
				@order.shipped
			when 4
				@order.delivered
			when 5 # dispute initiated
				armor_dispute_id = params[:event][:entity_id]
				@order.disputed(dispute_id: armor_dispute_id)
				# order dispute method TBD
			when 6
				@order.completed
			when 7 # dispute to arbitration
				@order.dispute_update
			when 10 # dispute offer made
				@order.dispute_update
			when 11 # dispute offer accepted
				@order.dispute_update
			when 13 # dispute offer countered
				@order.dispute_update
			when 1001
				@company.set_armor_bank
			else
				logger.info "Armor Webhook UNHANDLED EVENT -- TYPE: #{event_type} DESCRIPTION: #{params[:event][:description]}"
			end
		end
		render :nothing => true
	end

	private

	def get_order(order_id)
		@order = Order.find_by(armor_order_id: order_id)
		if @order.blank?
			logger.info "Armor Webhook Order Not Found. Order ID: #{order_id}"
		end
	end
	def get_company(account_id)
		@company = Brand.find_by(armor_account_id: account_id) || Retailer.find_by(armor_account_id: account_id) || Distributor.find_by(armor_account_id: account_id)
		if @company.blank?
			logger.info "Armor Webhook Company (w/ account) Not Found. Account ID: #{account_id}"
		end
	end

end