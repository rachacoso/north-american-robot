class CommentsController < ApplicationController

	def update
		@order = @current_user.company.orders.find(params[:id])
		@comment = @order.comments.find_by(order_status: @order.status)
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