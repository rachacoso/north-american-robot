module OrderItemsHelper
	def get_sorted_order_items(order)
		# return Hash[order.order_items.map{ |i| i.product.nil? ?  : [i, i.product] }.sort_by { |lineitem, product| product.item_id }]
		return order.order_items.order_by(:item_id.desc)
	end
end