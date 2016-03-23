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

	def get_brands(chunk,type)
		if type == "c"
			brands = Brand.activated.international.where(subsector_ids: chunk.id )
		elsif type == "t"
			brands = Brand.activated.international.where(trend_ids: chunk.id )
		elsif type == "kr"
			brands = Brand.activated.international.where(key_retailer_ids: chunk.id )
		end
		return brands
	end

end
