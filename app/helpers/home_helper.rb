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

	def get_order_companies(orders)
		if @current_user.brand
			order_companies = orders.map(&:orderer)
		else
			order_companies = orders.map(&:brand)
		end
			return order_companies.sort_by{ |o| o.company_name.to_s }
	end

	def get_order(company2)
		company1 = @current_user.get_parent
		if @current_user.type? == "brand"
			company1.orders.where(orderer: company2).first
		else
			company1.orders.where(brand: company2).first
		end
	end
end
