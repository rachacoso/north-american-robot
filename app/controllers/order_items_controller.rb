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

		if !@order  # create new order if doesnt exist
			@order = Order.new(
				orderer: @current_user.company,
				orderer_company_name: @current_user.company.company_name,
				ship_to_name: @current_user.company.company_name,
				user:  @current_user,
				brand: @order_product.brand,
				brand_company_name: @order_product.brand.company_name,
				armor_seller_account_id: @order_product.brand.armor_account_id,
				armor_seller_user_id: @order_product.brand.users.with_armor_user_id.first.armor_user_id,
				armor_seller_email: @order_product.brand.users.with_armor_user_id.first.email,
				armor_buyer_account_id: @current_user.company.armor_account_id,
				armor_buyer_user_id: @current_user.armor_user_id,
				armor_buyer_email: @current_user.email
				)
			@order.build_shipping_address(
				address1: @current_user.company.address.address1,
				address2: @current_user.company.address.address2,
				city: @current_user.company.address.city,
				state: @current_user.company.address.state,
				postcode: @current_user.company.address.postcode,
				country: @current_user.company.address.country,
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
			:quantity
			)
	end

	def set_product
		@order_product = Product.find(params[:product_id])
	end

	def get_order
		@order = Order.current.where(brand: @order_product.brand, orderer: @current_user.company).first
	end

end