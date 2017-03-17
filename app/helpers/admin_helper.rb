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

end
