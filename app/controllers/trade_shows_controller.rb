class TradeShowsController < ApplicationController

	def create
		u = @current_user.distributor || @current_user.brand
		new_item = u.trade_shows.create!(trade_show_parameters)
		save_date(params[:trade_show]['date(1i)'], params[:trade_show]['date(2i)'], new_item)
		@identifier = 'name'
		@new_item_id = new_item.id
		@collection = u.trade_shows

		# update COMPLETENESS
		if @current_user.distributor
			u.update_completeness
		end

		respond_to do |format|
			format.html
			format.js
		end 

	end

	def update
		u = @current_user.distributor || @current_user.brand
		collitem = u.trade_shows.find(params[:id])
		collitem.update!(trade_show_parameters)
		save_date(params[:trade_show]['date(1i)'], params[:trade_show]['date(2i)'], collitem)

		@identifier = 'name'
		@new_item_id = collitem.id
		@collection = u.trade_shows

		# update COMPLETENESS
		if @current_user.distributor
			u.update_completeness
		end

		respond_to do |format|
			format.html
			format.js
		end 

	end

	def destroy

		u = @current_user.distributor || @current_user.brand

		@collitemid = params[:id]
		d = TradeShow.find(@collitemid)
		@collection_name = d.class.to_s.downcase
		d.destroy
		@identifier = 'name'
		@collection = u.trade_shows
		@no_item_message = 'No Trade Shows'

		# update COMPLETENESS
		if @current_user.distributor
			u.update_completeness
		end

		respond_to do |format|
			format.html
			format.js
		end 

	end


  private
  def trade_show_parameters
    params.require(:trade_show).permit(
			:name,
			# :date,
			:country,
			:years_participated,
			:website
		)
	end

	def go_to_redirect(redir = nil)
		if @current_user.distributor
			
			if params[:ob] && redir #onboard and redirect
				redirect_to onboard_distributor_six_url + "#a-" + redir, :flash => { :make_active => redir }
			elsif params[:ob] #onboard no redirect
				redirect_to onboard_distributor_six_url
			elsif redir # main edit page and redirect
				redirect_to distributor_url + "#a-" + redir, :flash => { :make_active => redir }
			else # main edit page
				redirect_to distributor_url
			end

		else

			if params[:ob] && redir #onboard and redirect
				redirect_to onboard_brand_five_url + "#a-" + redir, :flash => { :make_active => redir }
			elsif params[:ob] #onboard no redirect
				redirect_to onboard_brand_five_url
			elsif redir # main edit page and redirect
				redirect_to brand_url + "#a-" + redir, :flash => { :make_active => redir }
			else # main edit page
				redirect_to brand_url
			end

		end
	end

end