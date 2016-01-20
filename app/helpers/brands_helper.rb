module BrandsHelper

	def index_item_photo(brand)
		if brand.all_product_photos.blank? && brand.brand_photos.blank?
			return "logo", brand.logo.url(:medium)
		elsif brand.all_product_photos.blank? 
			return "photo", brand.brand_photos.sample.photo.url(:medium)
		else 
			return "photo", brand.all_product_photos.sample.photo.url(:medium)
		end
	end

	def brand_tags(tag)
		tags = Tag.only(:taggable_id).where(name: tag, taggable_type: "Brand")
		return tags
	end

	def brand_tag_brands(tag)
		brands = Brand.activated.find(tag.taggable_id)
		return brands
	end

end
