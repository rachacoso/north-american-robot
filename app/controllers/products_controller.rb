class ProductsController < ApplicationController

	def create
		brand = @current_user.brand
		new_item = brand.products.create!(product_parameters)
		new_item.save_price(params[:product][:price])
		@identifier = 'name'
		@iscurrent = params[:product][:current]

		if @iscurrent == "true"
			# new_item = brand.products.create!(current: true)
			@collection = brand.products.where(current: true)
		else
			# new_item = brand.products.create!(current: false)
			@collection = brand.products.where(current: false)
		end

		@new_item_id = new_item.id

		if params[:ob]
			@ob = true
		else
			@ob = false
		end

		# PRODUCT TAGS
		@product_tags = Hash.new
		brand.products.each do |product|
			@product_tags[product.id] = product.tags
		end

		# @iscurrent ||= false
		respond_to do |format|
			format.html
			format.js
		end 
	
	end

	def update

		brand = @current_user.brand
		# @collitem = brand.products.find(params[:id])
		# @collitem.update!(product_parameters)

		collitem = brand.products.find(params[:id])
		collitem.update!(product_parameters)
		collitem.save_price(params[:product][:price])
		@identifier = 'name'
		@iscurrent = collitem.current
		@new_item_id = collitem.id

		# PRODUCT TAGS
		@product_tags = Hash.new
		brand.products.each do |product|
			@product_tags[product.id] = product.tags
		end


		if @iscurrent
			@collection = brand.products.where(current: true)
		else
			@collection = brand.products.where(current: false)
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
		d = Product.find(@collitemid)
		@iscurrent = d.current
		@collection_name = d.class.to_s.downcase
		d.destroy

		@identifier = 'name'

		# PRODUCT TAGS
		brand = @current_user.brand
		@product_tags = Hash.new
		brand.products.each do |product|
			@product_tags[product.id] = product.tags
		end

		brand = @current_user.brand
		if @iscurrent 
			@collection = brand.products.where(current: true)
			@no_item_message = 'No Current Products'
		else
			@collection = brand.products.where(current: false)
			@no_item_message = 'No Past Products'
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


  private
  def product_parameters
    params.require(:product).permit(
			:name,
			:description,
			# :msrp,
			:item_id,
			:item_size,
			:key_benefits,
			:country_of_manufacture,
			:current
		)
	end


end