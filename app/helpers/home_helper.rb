module HomeHelper

	def get_share_type(id)
		if Brand.find(id)
			return 'brand'
		elsif Distributor.find(id)
			return 'distributor'
		else
			return nil
		end
	end
	
	def get_main_article
		article = Article.active.order_by(:date.desc).first
		return article
	end

	def get_sub_articles
		articles = Article.active.order_by(:date.desc).skip(1)
		return articles
	end

end
