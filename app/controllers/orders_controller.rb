class OrdersController < ApplicationController

	before_action :set_order, only: [:show, :edit, :update, :destroy, :submit, :pending, :approve, :shipment, :paid, :delivered, :armor_disabled_delivered, :armor_disabled_completed, :complete]

	#setting of paid only done for testing & by admin only
	before_action :administrators_only, only: [:paid, :delivered, :complete]

	def index
		@profile = @current_user.get_parent
		@current_orders = @profile.orders.current.count
		@submitted_orders = @profile.orders.submitted.count
		@pending_orders = @profile.orders.pending.count
		@approved_orders = @profile.orders.approved.count
		@paid_orders = @profile.orders.paid.count
		@shipped_orders = @profile.orders.shipped.count
		@delivered_orders = @profile.orders.delivered.count
		@completed_orders = @profile.orders.completed.count
		@error_orders = @profile.orders.error.count
		@disputed_orders = @profile.orders.disputed.count
		@active_orders = @profile.orders.active.count
		if f = params[:f]
			if [
				"current", 
				"submitted", 
				"pending", 
				"approved",
				"paid",
				"shipped",
				"delivered",
				"disputed",
				"error",
				"completed",
				"active"
				].include? f
				@orders = @current_user.company.orders.send(f).order_by(:c_at => 'desc')
				@filter = f
			else
				@orders = @current_user.company.orders.active.order_by(:c_at => 'desc')
				@filter = "active"
			end		
		else
			@orders = @current_user.company.orders.active.order_by(:c_at => 'desc')
			@filter = "active"
		end

	end

	def show
		unless @order.viewable_by? @current_user
			redirect_to root_url
		end
		if @order.status == "approved"
			if @order.armor_enabled?
				url = @order.api_get_payment_url(@current_user)
				unless @order.errors.any?
					@armor_payment_instructions_url = url
				end
			else
				list = @order.api_get_shippers
				unless @order.errors.any?
					@armor_shippers_list = list
				end
			end
		elsif @order.status == "paid"
			if @order.armor_enabled?
				list = @order.api_get_shippers
				unless @order.errors.any?
					@armor_shippers_list = list
				end
			end
		elsif @order.status == "delivered"
			if @order.armor_enabled?
				url = @order.api_get_release_payment_url
				unless @order.errors.any?
					@armor_payment_release_payment_url = url
				end
				disputeurl = @order.api_get_dispute_url
				unless @order.errors.any?
					@armor_payment_dispute_url = disputeurl
				end
			end
		elsif @order.status == "disputed"
			disputeurl = @order.api_get_dispute_status_url(company: @current_user.company, user: @current_user)
			unless @order.errors.any?
				@armor_payment_dispute_url = disputeurl
			end
		end
	end

	def submit
		if params[:confirm].to_i == 1
			@order.submission(user: @current_user)
		end
		respond_to do |format|
			format.html  { redirect_to order_url(@order) }
			format.js
		end
	end

	def pending
		if params[:confirm].to_i == 1
			@order.pending(user: @current_user)
			if @order.errors.any?
				flash.now[:notice] = @order.errors.full_messages
			end
		end
		respond_to do |format|
			format.html  { redirect_to order_url(@order) }
			format.js
		end
	end

	def approve
		if params[:confirm].to_i == 1
			@order.approval
			if @order.errors.any?
				flash.now[:notice] = @order.errors.full_messages
			end
		end
		respond_to do |format|
			format.html  { redirect_to order_url(@order) }
			format.js
		end
	end

	def complete
		if params[:confirm].to_i == 1
			@order.completed_no_armor
			if @order.errors.any?
				flash.now[:notice] = @order.errors.full_messages
			else
				@success = true
				sleep(5) #pause to allow update of status from webhook
			end
		end
		respond_to do |format|
			format.html  { redirect_to order_url(@order) }
			format.js
		end
	end

	def shipment

			@order.api_add_shipment_info(
				carrier_id: params[:shipper_id],
				carrier_name: params[:shipper_name],
				tracking_id: params[:armor_shipment_tracking_number],
				description: params[:armor_shipment_description],
				other_shipper: params[:armor_other_shipper]
				)
			if @order.errors.any?
				flash.now[:error] = "Sorry, there was an error submitting your shipment details. <br> #{@order.errors.full_messages}"
				@armor_shippers_list = @order.api_get_shippers
				render :show
			else
				sleep(5) #pause to allow update of status from webhook
				redirect_to order_url(@order)
			end

	end

	# FOR TESTING ARMOR ONLY
	def paid
		if params[:confirm].to_i == 1
			@order.api_testing_set_to_paid
			if @order.errors.any?
				flash.now[:notice] = @order.errors.full_messages
			else
				@success = true
				sleep(5) #pause to allow update of status from webhook
			end
		end
		respond_to do |format|
			format.html  { redirect_to order_url(@order) }
			format.js
		end
	end

	def delivered
		if params[:confirm].to_i == 1
			@order.api_testing_set_to_delivered
			if @order.errors.any?
				flash.now[:notice] = @order.errors.full_messages
			else
				@success = true
				sleep(5) #pause to allow update of status from webhook
			end
		end
		respond_to do |format|
			format.html  { redirect_to order_url(@order) }
			format.js
		end
	end

	def armor_disabled_delivered
		if params[:confirm].to_i == 1
			@order.delivered
			@success = true
		end
		respond_to do |format|
			format.html  { redirect_to order_url(@order) }
			format.js
		end
	end

	def armor_disabled_completed
		if params[:confirm].to_i == 1
			@order.completed_no_armor
			@success = true
		end
		respond_to do |format|
			format.html  { redirect_to order_url(@order) }
			format.js
		end
	end

	def update
		@order.update(order_params)
		if !@order.save
			flash[:error] = "Sorry, Discount must be a number between 0 and 100"
		end
		redirect_to order_url(@order)
	end

	private

	def set_order
		if @current_user.administrator
			@order = Order.find(params[:id])
		else
			@order = @current_user.company.orders.find(params[:id])
		end
	end

	def order_params
		params.require(:order).permit(
			:discount,
			:ship_to_name,
			shipping_address_attributes: [
			  :address1,
			  :address2,
			  :city,
			  :state,
			  :postcode,
			  :country
			]
		)
	end
end