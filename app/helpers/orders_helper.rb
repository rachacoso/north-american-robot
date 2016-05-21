module OrdersHelper

	def current_order(brand)
		return brand.orders.current.where(orderer_id: @current_user.get_parent.id).first
	end

	def submitted_order(brand)
		return brand.orders.submitted.where(orderer_id: @current_user.get_parent.id).first
	end

	def pending_order(brand)
		return brand.orders.pending.where(orderer_id: @current_user.get_parent.id).first
	end

	def active_order(profile)
		if profile.class.to_s == "Brand"
			return profile.orders.active.where(orderer_id: @current_user.get_parent.id).first
		elsif profile.class.to_s == "Distributor" || profile.class.to_s == "Retailer"
			return profile.orders.active.where(brand: @current_user.get_parent.id).first
		end
	end
	def order_in_progress(profile)
		if profile.class.to_s == "Brand"
			return profile.orders.in_progress.where(orderer_id: @current_user.get_parent.id).first
		elsif profile.class.to_s == "Distributor" || profile.class.to_s == "Retailer"
			return profile.orders.in_progress.where(brand: @current_user.get_parent.id).first
		end
	end

	def shippers_list(list)
		tracking_list = []
		list.each do |s|
			tracking_list << { value:  s["name"], data: s["carrier_id"] }
		end
		return tracking_list.sort_by {|s| s[:value] }
	end

	def profile_link(company)
		case company.class.to_s
		when "Brand"
			return view_brand_url(company)
		when "Retailer"
			return view_retailer_url(company)
		when "Distributor"
			return view_distributor_url(company)
		end
	end
end