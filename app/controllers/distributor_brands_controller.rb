class DistributorBrandsController < ApplicationController

	def create
		distributor = @current_user.distributor
		new_item = distributor.distributor_brands.create!(distributor_brand_parameters)
		@identifier = 'brand'
		@iscurrent = params[:distributor_brand][:current]

		if @iscurrent == "true"
			# new_item = distributor.distributor_brands.create!(current: true)
			@collection = distributor.distributor_brands.where(current: true)
		else
			# new_item = distributor.distributor_brands.create!(current: false)
			@collection = distributor.distributor_brands.where(current: false)
		end

		@new_item_id = new_item.id

		# PRODUCT TAGS
		@product_tags = Hash.new
		distributor.distributor_brands.each do |product|
			@product_tags[product.id] = product.tags
		end

		if params[:ob]
			@ob = true
		else
			@ob = false
		end

		# update COMPLETENESS	
		distributor.update_completeness
		
		respond_to do |format|
			format.html
			format.js
		end 

	end

	def update
		distributor = @current_user.distributor
		collitem = distributor.distributor_brands.find(params[:id])
		collitem.update!(distributor_brand_parameters)

		@identifier = 'brand'
		@iscurrent = collitem.current
		@new_item_id = collitem.id

		# PRODUCT TAGS
		@product_tags = Hash.new
		distributor.distributor_brands.each do |product|
			@product_tags[product.id] = product.tags
		end


		if @iscurrent
			@collection = distributor.distributor_brands.where(current: true)
		else
			@collection = distributor.distributor_brands.where(current: false)
		end

		if params[:ob]
			@ob = true
		else
			@ob = false
		end

		respond_to do |format|
			format.html
			format.js
		end 

	end

	def destroy

		@collitemid = params[:id]
		d = DistributorBrand.find(@collitemid)
		@iscurrent = d.current
		@collection_name = d.class.to_s.downcase
		d.destroy

		@identifier = 'brand'

		distributor = @current_user.distributor

		# PRODUCT TAGS
		@product_tags = Hash.new
		distributor.distributor_brands.each do |product|
			@product_tags[product.id] = product.tags
		end


		if @iscurrent 
			@collection = distributor.distributor_brands.where(current: true)
			@no_item_message = 'No Current Brands'
		else
			@collection = distributor.distributor_brands.where(current: false)
			@no_item_message = 'No Past Brands'
		end

		if params[:ob]
			@ob = true
		else
			@ob = false
		end

		# update COMPLETENESS	
		distributor.update_completeness

		respond_to do |format|
			format.html
			format.js
		end 

	end


  private
  def distributor_brand_parameters
    params.require(:distributor_brand).permit(
			:brand,
			:category,
			:website,
			:country_of_manufacture,
			:current
		)
	end		

	def go_to_redirect(redir = nil)

		if params[:ob] && redir #onboard and redirect
			redirect_to onboard_distributor_five_url + "#a-" + redir, :flash => { :make_active => redir }
		elsif params[:ob] #onboard no redirect
			redirect_to onboard_distributor_five_url
		elsif redir # main edit page and redirect
			redirect_to distributor_url + "#a-" + redir, :flash => { :make_active => redir }
		else # main edit page
			redirect_to distributor_url
		end

	end

end