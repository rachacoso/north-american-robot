class OrderItemsController < ApplicationController

	before_action :set_product, :get_order, only: [:new, :create]

	def new
		if @order && item = @order.order_items.where(product_id: @order_product.id).first
			@order_item = item
			render :edit
		else
			@order_item = OrderItem.new
		end
	end

	def edit
		@order = @current_user.get_parent.orders.find(params[:o])
		@order_item = @order.order_items.find(params[:id])
		@order_product = @order_item.product
	end

	def update
		@order = @current_user.get_parent.orders.current.find(params[:o])
		if @order # only update if there is a current order
			@order_item = @order.order_items.find(params[:id])
			if params[:order_item][:quantity].to_i == 0
				@order_item.destroy
				flash.now[:notice] = "#{@order_item.name} has been removed from the order"
				if @order.order_items.empty?
					brand = @order.brand
					@order.destroy
					redirect_to view_brand_url(brand) and return
				end
			else
				@order_item.update!(order_item_parameters)
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

		if !@order && !@submitted_order && !@pending_order # create new order if doesnt exist (as open, submitted, or pending)
			@order = Order.new(
				orderer: @current_user.company,
				orderer_company_name: @current_user.company.company_name,
				user:  @current_user,
				brand: @order_product.brand,
				brand_company_name: @order_product.brand.company_name
				)
			@order.save!
		end
		if @order # only create/update if there is active order
			if params[:order_item][:quantity].to_i > 0
				@order_item = @order.order_items.find_or_create_by(product_id: @order_product.id) # dont product duplicate order items if somehow was already created
				@order_item.update(
					quantity: params[:order_item][:quantity].to_i,
					price: @order_product.price,
					name: @order_product.name,
					item_id: @order_product.item_id,
					item_size: @order_product.item_size
					 )
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