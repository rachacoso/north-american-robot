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

	def order_index_filterlist_class(group_type, link_type)
		if link_type == group_type
			return "class=active"
		else
			return nil
		end
	end

	def sortable_status(status)
		status_order = {
			"open" => "1" ,
			"submitted" => "2" ,
			"pending" => "3" ,
			"approved" => "4" ,
			"paid" => "5" ,
			"shipped" => "6" ,
			"delivered" => "7" ,
			"completed" => "8"
		}
		return "sorttable_customkey=#{status_order[status]}"
	end

	def sortable_date(date)
		if date.present?
			return "sorttable_customkey=#{date.strftime('%Y%m%d%H%M%S')}"
		else
			return "sorttable_customkey=00000000000000"
		end
	end

end
