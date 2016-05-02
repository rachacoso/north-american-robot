class OrdersController < ApplicationController

	before_action :set_order, only: [:show, :edit, :update, :destroy, :submit, :pending, :approve, :shipment]

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
		end
	end

	def submit
		if params[:confirm].to_i == 1
			@order.submission
		end
		respond_to do |format|
			format.html  { redirect_to order_url(@order) }
			format.js
		end
	end

	def pending
		if params[:confirm].to_i == 1
			@order.pending
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
			tracking_id: params[:armor_shipment_tracking_number], 
			description: params[:armor_shipment_description],
			other_shipper: params[:armor_other_shipper]
			)
		if @order.errors.any?
			flash[:error] = "Sorry, there was an error submitting your shipment details. <br> #{@order.errors.full_messages}"
			@armor_shippers_list = @order.api_get_shippers
			render :show
		else
			redirect_to order_url(@order)
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