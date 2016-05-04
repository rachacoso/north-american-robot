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

	def order_groupquery(orders, group_type, company)
		case group_type
		when "b"
			return orders.where(brand: company)
		when "d", "r"
			return orders.where(orderer: company)
		end
	end
end
