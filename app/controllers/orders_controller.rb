class OrdersController < ApplicationController

	before_action :set_order, only: [:show, :edit, :update, :destroy, :submit]

	def show

	end

	def submit
		if params[:confirm].to_i == 1
			@order.submission
			# @order.save!
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