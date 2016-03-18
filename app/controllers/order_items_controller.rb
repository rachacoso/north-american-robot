class OrderItemsController < ApplicationController

	before_action :set_item

	def new

	end

	def create
		brand = @order_item.brand
		if @current_user.type? == "retailer"
			order = brand.orders.where(status: "open", retailer_id: @current_user.retailer.id ).first
		elsif @current_user.type? == "distributor"
			order = brand.orders.where(status: "open", distributor_id: @current_user.distributor.id ).first
		end
		if order
			@order = order
		else
			order = Order.new
			@current_user.send(@current_user.type?).orders << order
			@current_user.orders << order
			brand.orders << order
			@order = order
		end
	end

	private

	def set_item
		@order_item = Product.find(params[:id])
	end

end