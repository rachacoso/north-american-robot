module OrdersHelper

	def current_order(brand)
		return @current_user.get_parent.orders.where(status: "open", brand_id: brand.id).first
	end

	def pending_order(brand)
		return @current_user.get_parent.orders.where(status: "pending", brand_id: brand.id).first
	end

end