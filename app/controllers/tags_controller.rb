class TagsController < ApplicationController

	def new

		seed = [
			"Certified Organic",
			"Handcrafted",
			"BPA-free",
			"Pthalate-free",
			"Sulfate-free",
			"All Natural",
			"No Synthetic Color",
			"Gluten-free",
			"Wheat-free",
			"Nut-free",
			"Fragrance-free",
			"No Animal Testing",
			"Halal",
			"GMO-free",
			"Recycled / Green Packaging",
			"Made In America",
			"Handcrafted",
			"Certified Organic",
			"All-natural Fabrics & Dyes"
		]

		if !params[:query].blank?
			q = params[:query]
			tagset_seed = seed.select{ |i| i[/#{q}/i] }
			tagset_users = Tag.any_of({"name": /#{q}/i}).pluck(:name).uniq
		else
			tagset_users = Tag.pluck(:name).uniq
			tagset_seed = seed
		end

		@taglist = tagset_seed.to_a | tagset_users.to_a
		@taglist.sort_by!{ |m| m.downcase }
		@list = Hash.new
		@list['suggestions'] = @taglist
		render json: @list

	  # respond_to do |format|
	  #   format.html
	  #   format.js
	  # end 		
	end



	def create

		type = params[:type]
		tid = params[:tid]
		# name = params[:tag][:name].split.map{ |x| (x==x.upcase ? x : x.capitalize) }.join(' ')

		name = params[:tag][:name].split.map{ |x| (x[0]==x[0].upcase ? x : x.capitalize) }.join(' ')

		case type
		when 'b'
			to_be_tagged = @current_user.brand
		when 'd'
			to_be_tagged = @current_user.distributor
		when 'p'
			id = params[:product_id]
			to_be_tagged = @current_user.brand.products.find(id)
			@product_tags = Hash.new
			to_be_tagged.brand.products.each do |product|
				@product_tags[product.id] = product.tags
			end			
		when 'db'
			id = params[:product_id]
			to_be_tagged = @current_user.distributor.distributor_brands.find(id)
			@product_tags = Hash.new
			to_be_tagged.distributor.distributor_brands.each do |product|
				@product_tags[product.id] = product.tags
			end					
		end
		
		unless params[:tag][:name].empty?
			to_be_tagged.tags.find_or_create_by(name: name)
		end
		
		@tags = to_be_tagged.tags
		@tid = tid

		

	  respond_to do |format|
	    format.html
	    format.js
	  end 


	end


	def destroy

		tid = params[:tid]
		id = params[:id]

		tag_to_delete = Tag.find(id)

		parent = tag_to_delete.taggable
		tag_to_delete.destroy

		@tags = parent.tags.not_in(id: tag_to_delete.id)
		@tid = tid

	  respond_to do |format|
	    format.html
	    format.js
	  end 		
	end

end
