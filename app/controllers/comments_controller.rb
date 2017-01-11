class CommentsController < ApplicationController

	def create
		if params[:comment][:text].present?
			@order = Order.find(params[:order_id])
			comment = @order.comments.create(text: params[:comment][:text], author: @current_user.type?)
			if comment.errors.any?
				flash.now[:error] = comment.errors.full_messages
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