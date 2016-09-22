module OrdersHelper

	def order_flow_cart(status:, step:)
		case step
		when "cart"
			return "done"
		when "submitted"
			unless status == "open"
				return "done"
			end
		when "pending"
			unless ["open","submitted"].include? status
				return "done"
			end
		when "approved"
			unless ["open","submitted","pending"].include? status
				return "done"
			end
		when "paid"
			unless ["open","submitted","pending","approved"].include? status
				return "done"
			end
		when "shipped"
			unless ["open","submitted","pending","approved","paid"].include? status
				return "done"
			end
		when "delivered"
			unless ["open","submitted","pending","approved","paid","shipped"].include? status
				return "done"
			end
		when "completed"
			unless ["open","submitted","pending","approved","paid","shipped","delivered"].include? status
				return "done"
			end
		end
	end
	def get_company(id)
		unless id.blank?
			return Brand.find(id) || Retailer.find(id) || Distributor.find(id)
		end
	end
	def get_company_type(id)
		if Brand.find(id)
			return "BRAND"
		elsif Retailer.find(id)
			return "RETAILER"
		elsif Distributor.find(id)
			return "DISTRIBUTOR"
		end
	end
	def show_orders(profile)
		if @current_user.type? == "brand"
			if profile.class.to_s == "Brand"
				return false
			else
				return true
			end
		else
			if profile.class.to_s == "Brand"
				return true
			else
				return false
			end
		end
	end
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
	def open_order(profile)
		if profile.class.to_s == "Brand"
			return profile.orders.current.where(orderer_id: @current_user.get_parent.id).first
		elsif profile.class.to_s == "Distributor" || profile.class.to_s == "Retailer"
			return profile.orders.current.where(brand: @current_user.get_parent.id).first
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
		if @current_user.administrator
			case company.class.to_s
			when "Brand"
				return admin_brand_view_url(company)
			when "Retailer"
				return admin_retailer_view_url(company)
			when "Distributor"
				return admin_distributor_view_url(company)
			end
		else
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

	def display_lineitem_name(lineitem)
		if lineitem.can_be_edited(controller: controller_name, user: @current_user)
			return link_to lineitem.name, edit_order_item_url(lineitem,o:lineitem.order.id), remote: true
		else
			return lineitem.name
		end
	end
	def display_lineitem_quantity(lineitem)
		unless lineitem.quantity.blank?
			if lineitem.can_be_edited(controller: controller_name, user: @current_user)
				return link_to lineitem.quantity, edit_order_item_url(lineitem,o:lineitem.order.id), remote: true
			else
				return lineitem.quantity
			end
		end
	end
	def display_lineitem_quantity_testers(lineitem)
		unless lineitem.quantity_testers.blank?
			if lineitem.can_be_edited(controller: controller_name, user: @current_user)
				return link_to lineitem.quantity_testers, edit_order_item_url(lineitem,o:lineitem.order.id), remote: true
			else
				return lineitem.quantity_testers
			end
		end
	end

	def display_shipping_address(order:)
		company = order.orderer

		name = order.ship_to_name.present? ? order.ship_to_name : company.company_name
		address1 = order.shipping_address.address1.present? ? order.shipping_address.address1 : company.address.address1
		address2 = order.shipping_address.address2.present? ? order.shipping_address.address2 : company.address.address2
		city = order.shipping_address.city.present? ? order.shipping_address.city : company.address.city
		state = order.shipping_address.state.present? ? order.shipping_address.state : company.address.state
		postcode = order.shipping_address.postcode.present? ? order.shipping_address.postcode : company.address.postcode
		country = order.shipping_address.country.present? ? order.shipping_address.country : company.address.country

		shipping_address = "<ul id='shipping-address'>"
		shipping_address += "<li>#{name}</li>" if name.present?
		shipping_address += "<li>#{address1}</li>" if address1.present?
		shipping_address += "<li>#{address2}</li>" if address2.present?
		shipping_address += "<li>"
		shipping_address += "#{city}" if city.present?
		shipping_address += " #{state}" if state.present?
		shipping_address += " #{postcode}" if postcode.present?
		shipping_address += "</li>"
		shipping_address += "<li>#{country}</li>" if country.present?
		shipping_address += "</ul>"

		return shipping_address.html_safe
	end

	def display_history_and_comments(order:)

	end

end