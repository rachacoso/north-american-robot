class CommentsController < ApplicationController

	def create
		if params[:comment][:text].present?
			@order = Order.find(params[:order_id])
			if params[:order_updated].to_datetime.utc.to_i == @order.u_at.to_datetime.utc.to_i
				comment = @order.comments.create(text: params[:comment][:text], author: @current_user.type?)
				@order.touch
				if comment.errors.any?
					flash.now[:error] = comment.errors.full_messages
				end
			else
				flash.now[:error] = "Hold On! #{ @current_user.type? == "brand" ? @order.orderer.company_name : @order.brand.company_name } has updated the order. <br>Please review the updated order before adding a comment.".html_safe
				@reload = true
				@comment = params[:comment][:text]
			end
		else
			flash.now[:error] = "Sorry! Please enter a comment."
		end
	end

	def update
		@order = @current_user.company.orders.find(params[:id])
		@comment = @order.comments.find(params[:comment_id])
		@comment.update(comment_params)
		if !@comment.save
			# flash.now[:error] = "Sorry, Discount must be a number between 0 and 100"
			flash.now[:error] = @comment.errors.full_messages
		end
	end

	def comment_params
		params.require(:comment).permit(
			:text
		)
	end
end