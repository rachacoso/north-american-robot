module OrderItemsHelper

	def order_item_display_price(price)
		return '%.2f' % (price.to_f / 100)
	end

end