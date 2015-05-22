class PressHitsController < ApplicationController
	require 'date'

	def create
		u = @current_user.distributor || @current_user.brand
		new_item = u.press_hits.create!(press_hit_parameters)
		# unless params[:press_hit][:date].empty?
		# 	new_item.date = Date.strptime(params[:press_hit][:date], '%Y-%m-%d')
		# 	new_item.save
		# end
		@identifier = 'source'
		@new_item_id = new_item.id
		
		@collection = u.press_hits

		respond_to do |format|
			format.html
			format.js
		end 

	end

	def update
		u = @current_user.distributor || @current_user.brand
		collitem = u.press_hits.find(params[:id])
		collitem.update!(press_hit_parameters)
		if params[:press_hit][:date]
			collitem.date = Date.strptime(params[:press_hit][:date], '%m/%d/%Y')
			collitem.save!
		end
		
		@identifier = 'source'
		@new_item_id = collitem.id
		
		@collection = u.press_hits

		respond_to do |format|
			format.html
			format.js
		end 

	end

	def file_destroy
		u = @current_user.distributor || @current_user.brand
		ph = u.press_hits.find(params[:id])
		ph.file = nil
		ph.save!

		go_to_redirect(params[:id])	

	end

	def destroy

		u = @current_user.distributor || @current_user.brand

		@collitemid = params[:id]
		d = PressHit.find(@collitemid)
		@collection_name = d.class.to_s.downcase
		d.destroy

		@identifier = 'source'
		@collection = u.press_hits
		@no_item_message = 'No Press Hits'

		respond_to do |format|
			format.html
			format.js
		end 

	end


  private
  def press_hit_parameters
    params.require(:press_hit).permit(
			:source,
			:date,
			:quotes,
			:link,
			:file
		)
	end		

	def go_to_redirect(redir = nil)

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
