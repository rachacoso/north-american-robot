class CompliancesController < ApplicationController

	def create
		u = @current_user.distributor || @current_user.brand

		new_item = u.compliances.create!(compliance_parameters)
		save_date(params[:compliance]['date(1i)'], params[:compliance]['date(2i)'], new_item)
		@identifier = 'product_or_category'
		@new_item_id = new_item.id
		@collection = u.compliances
		respond_to do |format|
			format.html
			format.js
		end 

	end

	def update
		u = @current_user.distributor || @current_user.brand
		collitem = u.compliances.find(params[:id])
		collitem.update!(compliance_parameters)
		save_date(params[:compliance]['date(1i)'], params[:compliance]['date(2i)'], collitem)
		@identifier = 'product_or_category'
		@new_item_id = collitem.id
		@collection = u.compliances

		respond_to do |format|
			format.html
			format.js
		end 

	end

	def destroy

		u = @current_user.distributor || @current_user.brand

		@collitemid = params[:id]
		d = Compliance.find(@collitemid)
		@collection_name = d.class.to_s.downcase
		d.destroy
		@identifier = 'product_or_category'
		@collection = u.compliances
		@no_item_message = 'No Certifications/Regulatory Compliance'

		respond_to do |format|
			format.html
			format.js
		end 

	end


  private
  def compliance_parameters
    params.require(:compliance).permit(
			:product_or_category,
			:compliance_description,
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
