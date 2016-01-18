module BrandsHelper

	def index_item_photo(brand)
		if brand.all_product_photos.blank?
			return "logo", brand.logo.url(:medium)
		else
			return "photo", brand.all_product_photos.sample.photo.url(:small)
		end
	end

end
