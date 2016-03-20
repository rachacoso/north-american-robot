class OrderItemsController < ApplicationController

	before_action :set_product, :get_open_order

	def new
		if @order && item = @order.order_items.where(product_id: @order_product.id).first
			@order_item = item
		else
			@order_item = OrderItem.new
		end
	end

	def update
		@order_item = @order.order_items.find(params[:id])
		if params[:order_item][:quantity].to_i == 0
			@order_item.destroy
			flash.now[:notice] = "#{@order_product.name} has been removed from the order"
		else
			@order_item.update!(order_item_parameters)
		end
	end

	def create

		unless @order # create new order if doesnt exist
			order = Order.new
			@current_user.get_parent.orders << order
			@current_user.orders << order
			@order_product.brand.orders << order
			@order = order
		end
		if params[:order_item][:quantity].to_i > 0
			@order_item = OrderItem.new(product_id: @order_product.id, quantity: params[:order_item][:quantity].to_i)
			@order.order_items << @order_item
		else
			flash.now[:error] = "Sorry, please enter a vaild quantity"
			@order_item = OrderItem.new
			respond_to do |format|
				format.html  { render :new }
				format.js { render :new }
			end
		end
	end

	private

	def order_item_parameters
		params.require(:order_item).permit(
			:quantity
			)
	end

	def set_product
		@order_product = Product.find(params[:product_id])
	end

	def get_open_order
		if @current_user.type? == "retailer"
			@order = @order_product.brand.orders.where(status: "open", retailer_id: @current_user.retailer.id ).first
		elsif @current_user.type? == "distributor"
			@order = @order_product.brand.orders.where(status: "open", distributor_id: @current_user.distributor.id ).first
		end
	end

end