class OrdersController < ApplicationController

	before_action :set_order, only: [:show, :edit, :update, :destroy, :submit]

	def show

	end

	def submit
		if params[:confirm].to_i == 1
			@order.status = "submitted"
			@order.save!
		end
		respond_to do |format|
			format.html  { redirect_to order_url(@order) }
			format.js
		end
	end

	private

	def set_order
		@order = Order.find(params[:id])
	end

end