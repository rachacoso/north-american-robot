class OrdersController < ApplicationController

	before_action :set_order, only: [:show, :edit, :update, :destroy, :finalize]

	def show

	end

	def finalize
		if params[:confirm].to_i == 1
			@order.status = "pending"
			@order.save!
		end
	end

	private

	def set_order
		@order = Order.find(params[:id])
	end

end