class OrderItemsController < ApplicationController

	before_action :set_product, :get_order, only: [:new, :create]

	def new

		@order_item = OrderItem.get_item(product: @order_product, orderer: @current_user.company)

	end

	def edit
		@order = @current_user.get_parent.orders.find(params[:o])
		@order_item = @order.order_items.find(params[:id])
		@order_product = @order_item.product
	end

	def update
		if request.referer.include? "orders" # for profile button updates
			@section = "cart"
		else
			@section = "profile"
		end
		@order = @current_user.get_parent.orders.editable.find(params[:o])
		if @order # only update if there is an editable order
			@order_item = @order.order_items.find(params[:id])
			params[:order_item][:quantity] = nil if params[:order_item][:quantity].to_i == 0
			params[:order_item][:quantity_testers] = nil if params[:order_item][:quantity_testers].to_i == 0
			@order_item.update!(order_item_parameters)
			if ( @order_item.quantity.blank? || @order_item.quantity.to_i == 0 ) && ( @order_item.quantity_testers.blank? || @order_item.quantity_testers.to_i == 0 ) 
				@order_item.destroy
				flash.now[:notice] = "#{@order_item.name} has been removed from the order"
				if @order.order_items.empty?
					brand = @order.brand
					@order.destroy
					redirect_to view_brand_url(brand) and return
				end
			end
			respond_to do |format|
				format.html  { redirect_to order_url(@order) }
				format.js
			end
		else
			redirect_to root_url
		end
	end

	def create
		if request.referer.include? "orders" # for profile button updates
			@section = "cart"
		else
			@section = "profile"
		end

		if !@order  # create new order if doesnt exist
			@order = Order.create_new(user: @current_user, brand: @order_product.brand)
		end
		if @order # only create/update if there is active order
			if params[:order_item][:quantity].to_i > 0 || params[:order_item][:quantity_testers].to_i > 0 
				@order_item = @order.order_items.find_or_create_by(product_id: @order_product.id) # dont product duplicate order items if somehow was already created
				if params[:order_item][:quantity].to_i == 0
					params[:order_item][:quantity] = nil
				end
				if params[:order_item][:quantity_testers].to_i == 0
					params[:order_item][:quantity_testers] = nil
				end
				@order_item.update(
					quantity: params[:order_item][:quantity],
					quantity_testers: params[:order_item][:quantity_testers],
					price: @order_product.price,
					name: @order_product.name,
					item_id: @order_product.item_id,
					item_size: @order_product.item_size
					 )
			else
				flash.now[:error] = "Sorry, please enter a vaild quantity"
				@order_item = OrderItem.get_item(product: @order_product, orderer: @current_user.company)
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
			:quantity,
			:quantity_testers
			)
	end

	def set_product
		@order_product = Product.find(params[:product_id])
	end

	def get_order
		@order = Order.current.where(brand: @order_product.brand, orderer: @current_user.company).first
	end

end