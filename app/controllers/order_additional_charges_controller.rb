class OrderAdditionalChargesController < ApplicationController

	def create
		@order = Order.find(params[:order_id])
		if params[:order_additional_charge][:amount].present? && params[:order_additional_charge][:name].present?
			new_charge = @order.order_additional_charges.create(order_additional_charge_params)
			new_charge.set_amount(params[:order_additional_charge][:amount])
			new_charge.save!
		else
			flash[:error] = "Please input a NAME and AMOUNT"
		end
		redirect_to order_url(@order)
	end

	def update
		@order = Order.find(params[:order_id])
		add_charge = @order.order_additional_charges.find(params[:id])
		@order = add_charge.order
		add_charge.update(order_additional_charge_params)
		add_charge.set_amount(params[:order_additional_charge][:amount])
		redirect_to order_url(@order)
	end

	def destroy
		@order = Order.find(params[:order_id])
		delete_charge = @order.order_additional_charges.find(params[:id])
		delete_charge.destroy
		redirect_to order_url(@order)
	end

	private

	def order_additional_charge_params
		params.require(:order_additional_charge).permit(
			:name,
			:description
		)
	end
end