class OrderAdditionalChargesController < ApplicationController

	def create
		@order = Order.find(params[:order_id])
		if params[:order_additional_charge][:amount].present? && params[:order_additional_charge][:name].present?
			new_charge = @order.order_additional_charges.create(order_additional_charge_params)
			new_charge.set_amount(params[:order_additional_charge][:amount])
			new_charge.save!
			@message = "Added"
		else
			flash.now[:error] = "Please input a NAME and AMOUNT"
		end
		respond_to do |format|
			format.html  { redirect_to order_url(@order) }
			format.js { render 'orders/additional_charges' }
		end
	end

	def update
		@order = Order.find(params[:order_id])
		add_charge = @order.order_additional_charges.find(params[:id])
		@order = add_charge.order
		add_charge.update(order_additional_charge_params)
		add_charge.set_amount(params[:order_additional_charge][:amount])
		@message = "Updated"
		respond_to do |format|
			format.html  { redirect_to order_url(@order) }
			format.js { render 'orders/additional_charges' }
		end
	end

	def destroy
		@order = Order.find(params[:order_id])
		delete_charge = @order.order_additional_charges.find(params[:id])
		delete_charge.destroy
		@message = "Deleted"
		respond_to do |format|
			format.html  { redirect_to order_url(@order) }
			format.js { render 'orders/additional_charges' }
		end
	end

	private

	def order_additional_charge_params
		params.require(:order_additional_charge).permit(
			:name,
			:description
		)
	end
end