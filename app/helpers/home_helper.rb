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

	def order_status(order)
		status = order.status
		case status
		when "open"
			return "<span id='#{status.downcase}'>STARTED</span> on #{order.c_at.strftime('%b %d, %Y')}"
		when "submitted"
			return "<span id='#{status.downcase}'>SUBMITTED</span> on #{order.submission_date.strftime('%b %d, %Y')}"
		when "pending"
			return "<span id='#{status.downcase}'>PENDING</span> on #{order.pending_date.strftime('%b %d, %Y')}"
		end
	end

end
