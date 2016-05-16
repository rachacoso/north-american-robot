class OrdersController < ApplicationController

	before_action :set_order, only: [:show, :edit, :update, :destroy, :submit, :pending, :approve, :shipment, :paid, :delivered]

	#setting of paid only done for testing & by admin only
	before_action :administrators_only, only: [:paid]

	def show
		unless @order.viewable_by? @current_user
			redirect_to root_url
		end
		if @order.status == "approved"
			url = @order.api_get_payment_url(@current_user)
			unless @order.errors.any?
				@armor_payment_instructions_url = url
			end
		elsif @order.status == "paid"
			list = @order.api_get_shippers
			unless @order.errors.any?
				@armor_shippers_list = list
			end
		elsif @order.status == "delivered"
			url = @order.api_get_release_payment_url
			unless @order.errors.any?
				@armor_payment_release_payment_url = url
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

	def update
		@order.update(order_params)
		if !@order.save
			flash[:error] = "Sorry, Discount must be a number between 0 and 100"
		end
		redirect_to order_url(@order)
	end

	private

	def set_order
		@order = Order.find(params[:id])
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