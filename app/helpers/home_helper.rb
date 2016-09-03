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

	def get_grid_articles
		articles = Article.active.order_by(:date.desc).limit(6)
		return articles
	end

	def get_remaining_articles
		articles = Article.active.order_by(:date.desc).skip(6)
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
		when "approved"
			return "<span id='#{status.downcase}'>APPROVED</span> on #{order.approved_date.strftime('%b %d, %Y')}"
		when "paid"
			return "<span id='#{status.downcase}'>PAYMENT IN ESCROW</span> on #{order.paid_date.strftime('%b %d, %Y')}"
		when "shipped"
			return "<span id='#{status.downcase}'>SHIPPED</span> on #{order.shipped_date.strftime('%b %d, %Y')}"
		when "delivered"
			return "<span id='#{status.downcase}'>DELIVERED</span> on #{order.delivered_date.strftime('%b %d, %Y')}"
		when "completed"
			if order.armor_enabled?
				return "<span id='#{status.downcase}'>COMPLETED (PAYMENT RELEASED)</span> on #{order.completed_date.strftime('%b %d, %Y')}"
			else
				return "<span id='#{status.downcase}'>COMPLETED</span> on #{order.completed_date.strftime('%b %d, %Y')}"
			end
		when "error"
			return "<span id='#{status.downcase}'>IN ERROR</span> on #{order.error_date.strftime('%b %d, %Y')}"
		when "disputed"
			return "<span id='#{status.downcase}'>IN DISPUTE</span> on #{order.disputed_date.strftime('%b %d, %Y')}"

		end
	end

end
