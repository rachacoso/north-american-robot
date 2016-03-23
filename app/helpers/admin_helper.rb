module AdminHelper

	def order_groupname(group_type)
		case group_type
		when "d"
			return "Distrbutor"
		when "r"
			return "Retailer"
		when "b"
			return "Brand"
		end
	end

	def order_groupquery(orders, group_type, group_item)
		case group_type
		when "b"
			return orders.where(brand: group_item)
		when "d", "r"
			return orders.where(orderer: group_item)
		end
	end
end
