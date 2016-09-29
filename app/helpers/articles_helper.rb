module ArticlesHelper

	def get_article_type(type)
		case type
		when 1
			return "BRAND SPOTLIGHT"
		when 2
			return "TREND REPORT"
		when 3
			return "PRODUCT SPOTLIGHT"
		when 4
			return "HOW TO"
		end

	end

	def get_brand_photo(brand)
    product_list = brand.products.pluck(:id)
    if photo = ProductPhoto.where(:photographable_id.in => product_list).shuffle[0]
	    return photo
	  elsif brand.brand_photos.shuffle[0]
			return brand.brand_photos.shuffle[0]
		else 
			return false
	  end
	end

	def get_tile_photo_url(article)
		if article.tile_photo.present?
			return article.tile_photo.url(:tile)
		elsif article.article_photos.present?
			return article.article_photos.first.photo.url(:large)
		end
	end

	def get_brand_photo_backup(brand)
    return brand.brand_photos.shuffle[0]
	end

	def get_product_photo(product)
    return ProductPhoto.where(photographable_id: product.id).shuffle[0]
	end


end