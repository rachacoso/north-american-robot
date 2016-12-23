class InventoryAdjustmentsController < ApplicationController

	before_action :set_product, only: [:new,:create]
	before_action :set_adjustment, only: [:edit,:update]
	# before_action :administrators_only, only: [:edit,:update]

	def index
		@brand = @current_user.brand
	end

	def new
		@adjustment = @product.inventory_adjustments.build
		@type = params[:type]
		@unfulfilled_requests = @product.inventory_adjustments.unfulfilled_requests if @type == "shipment"
		@unfulfilled_shipments = @product.inventory_adjustments.unfulfilled_shipments if @type == "received"
	end

	def create
		adjustment = @product.inventory_adjustments.create(inventory_adjustment_parameters)
		@brand = @product.brand
		adjustment.shipment_add_associated(params[:associated_requests]) if params[:associated_requests]
		adjustment.received_shipment_add_associated(params[:associated_shipments]) if params[:associated_shipments]
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
		@adjustment.update(inventory_adjustment_parameters)
		@brand = @adjustment.product.brand
		@adjustment.shipment_add_associated(params[:associated_requests]) if params[:associated_requests]
		@adjustment.received_shipment_add_associated(params[:associated_shipments]) if params[:associated_shipments]
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
			:comment
		)
	end
end