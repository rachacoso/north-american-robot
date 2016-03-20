module OrdersHelper

	def current_order(brand)
		return @current_user.get_parent.orders.where(brand_id: brand.id).first
	end

end