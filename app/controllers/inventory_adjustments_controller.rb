class InventoryAdjustmentsController < ApplicationController

	before_action :set_product, only: [:new,:create]
	before_action :set_adjustment, only: [:edit,:update]
	before_action :administrators_only, only: [:edit,:update]

	def new
		@adjustment = @product.inventory_adjustments.build
		@type = params[:type]
	end

	def create
		@product.inventory_adjustments.create(inventory_adjustment_parameters)
		@brand = @product.brand
	end

	def edit
	end

	def update
		@adjustment.update(inventory_adjustment_parameters)
		@brand = @adjustment.product.brand
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
			:amount,
			:type,
			:comment
		)
	end
end