class OrderItemsController < ApplicationController

	before_action :set_product, :get_order

	def new
		if @order && item = @order.order_items.where(product_id: @order_product.id).first
			@order_item = item
		else
			@order_item = OrderItem.new
		end
	end

	def update
		if @order # only update if there is active order
			@order_item = @order.order_items.find(params[:id])
			if params[:order_item][:quantity].to_i == 0
				@order_item.destroy
				flash.now[:notice] = "#{@order_product.name} has been removed from the order"
			else
				@order_item.update!(order_item_parameters)
			end
			respond_to do |format|
				format.html  { redirect_to order_url(@order) }
				format.js
			end
		else
			redirect_to view_brand_url(@order_product.brand)
		end
	end

	def create

		if !@order && !@submitted_order && !@pending_order # create new order if doesnt exist (as open, submitted, or pending)
			new_order = Order.new
	    new_order.orderer = @current_user.get_parent
	    new_order.user = @current_user
	    new_order.brand = @order_product.brand
	    new_order.save!
			@order = new_order
		end
		if @order # only create/update if there is active order
			if params[:order_item][:quantity].to_i > 0
				@order_item = @order.order_items.find_or_create_by(product_id: @order_product.id) # dont product duplicate order items if somehow was already created
				@order_item.update(quantity: params[:order_item][:quantity].to_i)
			else
				flash.now[:error] = "Sorry, please enter a vaild quantity"
				@order_item = OrderItem.new
				respond_to do |format|
					format.html  { render :new }
					format.js { render :new }
				end
			end
		else
			redirect_to view_brand_url(@order_product.brand)
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

	def get_order
		@order = @order_product.brand.orders.current.where(orderer_id: @current_user.get_parent.id ).first
		@submitted_order = @order_product.brand.orders.submitted.where(orderer_id: @current_user.get_parent.id ).first
		@pending_order = @order_product.brand.orders.pending.where(orderer_id: @current_user.get_parent.id ).first
	end

end