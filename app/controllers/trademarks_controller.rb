class TrademarksController < ApplicationController

	def create
		u = @current_user.distributor || @current_user.brand
		new_item = u.trademarks.create!(trademark_parameters)
		save_date(params[:trademark]['date(1i)'], params[:trademark]['date(2i)'], new_item)
		@identifier = 'product'
		@new_item_id = new_item.id
		@collection = u.trademarks
		respond_to do |format|
			format.html
			format.js
		end 

	end

	def update
		u = @current_user.distributor || @current_user.brand
		collitem = u.trademarks.find(params[:id])
		collitem.update!(trademark_parameters)
		save_date(params[:trademark]['date(1i)'], params[:trademark]['date(2i)'], collitem)
		@identifier = 'product'
		@new_item_id = collitem.id
		@collection = u.trademarks

		respond_to do |format|
			format.html
			format.js
		end 

	end

	def destroy

		u = @current_user.distributor || @current_user.brand

		@collitemid = params[:id]
		d = Trademark.find(@collitemid)
		@collection_name = d.class.to_s.downcase
		d.destroy
		@identifier = 'product'
		@collection = u.trademarks
		@no_item_message = 'No Trademarks'

		respond_to do |format|
			format.html
			format.js
		end 

	end


  private
  def trademark_parameters
    params.require(:trademark).permit(
			:product,
			:trademark_description,
			:country,
			# :date,
			:status
		)
	end		

	def go_to_redirect(redir = nil)

		if params[:ob] && redir #onboard and redirect
			redirect_to onboard_brand_eight_url + "#a-" + redir, :flash => { :make_active => redir }
		elsif params[:ob] #onboard no redirect
			redirect_to onboard_brand_eight_url
		elsif redir # main edit page and redirect
			redirect_to brand_url + "#a-" + redir, :flash => { :make_active => redir }
		else # main edit page
			redirect_to brand_url
		end

	end

end
