class InventoryAdjustmentsController < ApplicationController

	before_action :set_product, only: [:new,:create,:view_table]
	before_action :set_adjustment, only: [:edit,:update, :destroy]
	# before_action :administrators_only, only: [:edit,:update]

	def view_table

	end

	def index
		if params[:product]
			@product = Product.find(params[:product])
		end
		@brand = @current_user.brand
	end

	def new
		@adjustment = @product.inventory_adjustments.build
		@type = params[:type]
		@unfulfilled_requests = @product.inventory_adjustments.unfulfilled_requests if @type == "shipment"
		@unfulfilled_shipments = @product.inventory_adjustments.unfulfilled_shipments if @type == "received"
	end

	def create
		if params[:inventory_adjustment][:ship_date].present?
			params[:inventory_adjustment][:ship_date] = Date.strptime(params[:inventory_adjustment][:ship_date], '%m-%d-%Y') 
		end
		@adjustment = @product.inventory_adjustments.create(inventory_adjustment_parameters)
		if @adjustment.valid?
			@adjustment.shipment_add_associated(params[:associated_requests]) if params[:associated_requests]
			@adjustment.received_shipment_add_associated(params[:associated_shipments]) if params[:associated_shipments]
			@adjustment.mailer_send_notice
		end
		@brand = @product.brand

	end

	def edit
		if @adjustment.type == "shipment"
			unfulfilled = @adjustment.product.inventory_adjustments.unfulfilled_requests
			current = @adjustment.associated_requests
			@associated_requests = (unfulfilled + current).uniq
		end
		if @adjustment.type == "received"
			unfulfilled = @adjustment.product.inventory_adjustments.unfulfilled_shipments
			current = @adjustment.associated_shipments
			@associated_shipments = (unfulfilled + current).uniq
		end
	end

	def update
		if params[:inventory_adjustment][:ship_date].present?
			params[:inventory_adjustment][:ship_date] = Date.strptime(params[:inventory_adjustment][:ship_date], '%m-%d-%Y') 
		end
		@adjustment.cache_previous_data
		@adjustment.update(inventory_adjustment_parameters)
		if @adjustment.valid?
			@adjustment.shipment_add_associated(params[:associated_requests]) if params[:associated_requests]
			@adjustment.received_shipment_add_associated(params[:associated_shipments]) if params[:associated_shipments]
			@adjustment.mailer_send_update_notice
		end
		@brand = @adjustment.product.brand
		@product = @adjustment.product
	end

	def destroy
		@brand = @adjustment.product.brand
		if @adjustment.type == "received" #can only delete 'received' inventory adjustments
			@adjustment.associated_shipments.each do |shipment|
				shipment.associated_received_shipments.delete(@adjustment)
			end
			@adjustment.destroy
		end
		@product = @adjustment.product
	end

	private
	def set_product
		@product = Product.find(params[:product_id])
	end

	def set_adjustment
		@adjustment = InventoryAdjustment.find(params[:id])
	end

  def inventory_adjustment_parameters
    params.require(:inventory_adjustment).permit(
			:units,
			:type,
			:comment,
			:ship_date
		)
	end
end