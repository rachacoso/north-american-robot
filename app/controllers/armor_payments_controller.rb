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
				flash.now[:error] = "Sorry, there was an error, please try again:"
				flash.now[:errorlist] = u.errors.full_messages
			else
				flash[:newaccount] = true
			end
		else
			flash.now[:error] = "Sorry, you must agree to Armor Payments Terms and Conditions"
		end

    respond_to do |format|
      format.html { redirect_to eval("#{u.company_type.downcase}_url") + "#a-armor" } 
      format.js
    end

	end


	def webhook

		# ARMOR ORDER STATUSES
		# full list at http://www.armorpayments.com/api/classes/ArmorPayments.Api.Entity.Order.html
		# STATUS_PAID = 2
		# # Payment for the Order has been made, and is held in escrow
		# STATUS_SHIPPED = 3
		# # Goods to complete the order have been shipped
		# STATUS_DELIVERED = 4
		# # Goods to complete the order have been delivered to the buyer
		# STATUS_RELEASED = 5
		# # Payment for the Order has been released from escrow
		# STATUS_PENDING_INCOMPLETE = 6
		# # Seller's banking details are missing or incomplete
		# STATUS_PENDING_ERROR = 7
		# # There was an error transferring payment to the seller. This is most often caused by incorrect banking details.
		# STATUS_DISPUTE = 8
		# # A Dispute has been initiated for this Order
		# STATUS_COMPLETE = 9
		# The Order is complete, and final payment has been made. This is an internal Armor Payments status, and indicates that # Armor Payments has closed the books on this order. This will occur simetime after your users have finished their last interaction with the order. It is included here because if you look up an old order, you may see this status and need to know what it represents, but is for reference only.
		# STATUS_CANCELLED = 10
		# # The Order has been cancelled
		# STATUS_ARBITRATION = 11
		# # The Dispute for this Order has been escalated to 3rd party arbitration
		# STATUS_MILESTONE_PROGRESS = 15
		# # A milestone order with at least one completed milestone, awaiting next milestone completion.
		# STATUS_MILESTONE_PENDING = 16
		# # The milestone order has a completed milestone, awaiting release of milestone payment by buyer.
		# STATUS_SERVICE_PROGRESS = 17
		# # A non-milestone service order awaiting completion by service provider.
		# STATUS_SERVICE_PENDING = 18
		# # A non-milestone services order awaiting payment release by buyer.
		# STATUS_CANCELLED_FINAL = 98
		# # Order has been cancelled, and archived
		# STATUS_ARCHIVE = 99
		# # The Order is complete, and has been archived
		# STATUS_ERROR = 255
		# # There is an error with the Order

		if params[:order].present?

			if order = Order.find_by(armor_order_id: params[:order][:order_id])
				# case params[:order][:status]
				# when 0 # new
				# 	logger.info "Armor Webhook Order Status 0 (new order): #{order.id}"
				# when 1 # sent
				# 	logger.info "Armor Webhook Order Status 1 (order sent): #{order.id}"
				# when 2 # paid
				# 	order.paid
				# when 3 # shipped
				# 	order.shipped
				# when 4 # delivered
				# 	order.delivered
				# when 5 # payment released
				# 	order.completed
				# else # all other statuses
				# 	order.error(status: params[:order][:status],message: params[:order][:status_name])
				# end
				case params[:event][:type]
				when 0 # create
					logger.info "Armor Webhook Order Status 0 (new order): #{order.id}"
				when 2 # sent
					logger.info "Armor Webhook Order Status 1 (order sent): #{order.id}"
				when 2 # paid
					order.paid
				when 3 # shipped
					order.shipped
				when 4 # delivered
					order.delivered
				when 6 # payment released
					order.completed
				else # all other statuses
					order.error(status: params[:event][:type],message: params[:event][:description])
				end
			else
				logger.info "Armor Webhook Order Not Found: #{params[:order][:order_id]}"
			end

			# render :text => "Status: #{params[:order][:status]}, Status Name: #{params[:order][:status_name]}"
		end
		render :nothing => true
	end


end