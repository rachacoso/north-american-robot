module ArticlesHelper

	def get_article_type(type)
		case type
		when 1
			return "BRANDS"
		when 2
			return "TRENDS"
		end
	end

	def get_brand_photo(brand)
    product_list = brand.products.pluck(:id)
    return ProductPhoto.where(:photographable_id.in => product_list).shuffle[0]
	end
	
	def get_brand_photo_backup(brand)
    return brand.brand_photos.shuffle[0]
	end

end