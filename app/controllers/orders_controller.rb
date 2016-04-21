class OrdersController < ApplicationController

	before_action :set_order, only: [:show, :edit, :update, :destroy, :submit, :pending]

	def show
		unless @order.viewable_by? @current_user
			redirect_to root_url
		end
		if @order.status == "pending"
			url = @order.api_get_payment_url(@current_user)
			unless @order.errors.any?
				@armor_payment_instructions_url = url
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
			:discount
		)
	end
end