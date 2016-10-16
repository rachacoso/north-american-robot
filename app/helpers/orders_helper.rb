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

	def post_delivery_chart(status:, step:)
		case step
		when "warehouse"
			return "done"
		when "sent"
			unless status == "warehouse"
				return "done"
			end
		when "received"
			unless ["warehouse","sent"].include? status
				return "done"
			end
		when "awaiting"
			unless ["warehouse","sent","received"].include? status
				return "done"
			end
		when "paid"
			unless ["warehouse","sent","received","awaiting"].include? status
				return "done"
			end
		end
	end

	def post_delivery_header(order:)
		case order.post_delivery_status
		when "warehouse"
			return "Order at U.S. warehouse"
		when "sent"
			return "Order sent to #{order.orderer_company_name}"
		when "received"
			return "Order received by #{order.orderer_company_name}"
		when "awaiting"
			return "Awaiting payment from #{order.orderer_company_name}"
		when "paid"
			return "Paid by #{order.orderer_company_name}<br><small>You should be receiving payment shortly</small>".html_safe
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

		shipping_address = ""
		shipping_address += "<li>#{name}</li>" if name.present?
		shipping_address += "<li>#{address1}</li>" if address1.present?
		shipping_address += "<li>#{address2}</li>" if address2.present?
		shipping_address += "<li>"
		shipping_address += "#{city}" if city.present?
		shipping_address += " #{state}" if state.present?
		shipping_address += " #{postcode}" if postcode.present?
		shipping_address += "</li>"
		shipping_address += "<li>#{country}</li>" if country.present?

		return shipping_address.html_safe
	end

	def get_order_terms(order:)
	
		shipping_payment_terms = []
		order_requirements = []

		payment_terms = order.payment_terms if order.payment_terms.present?

		case terms = order.us_shipping_terms
		when "Brand", "Retailer"
			us_shipping_terms = terms
		when nil
			us_shipping_terms = nil
		else #when 'Other'
			matched_terms = terms.match(/^Other - (.+)/m).captures.first rescue nil
			us_shipping_terms = "(Other Shipping Terms) <br>".html_safe + matched_terms
		end

		#check accepts_overseas_shipment
		if order.accepts_overseas_shipment
			shipping_payment_terms << "Accepts Overseas Shipment"
		else
			shipping_payment_terms << "Requires U.S. Fulfillment"
		end

		# ORDER REQUIREMENTS

		if order.margin.present?
			order_requirements << "Margin: #{order.discount}%"
		end

		if order.marketing_co_op.present?
			order_requirements << "Marketing Co-Op: #{order.marketing_co_op}%"
		end

		if order.damages_budget.present?
			order_requirements << "Damages Budget: #{order.damages_budget}%"
		end

		order_requirements << "Product Ticketing" if order.product_ticketing
		order_requirements << "Retailer EDI" if order.retailer_edi


		return payment_terms, us_shipping_terms, shipping_payment_terms, order_requirements

	end

	def display_history_and_comments(order:)

	end

	def estimated_payment_date(order:)
		if order.payment_terms.blank? || order.payment_terms == "Prepayment"
			ship_date = "5 days after receipt of products"
		else
			if order.cancel_date.present?
				case order.payment_terms
				when "Net 30"
					ship_date = (order.cancel_date + 35)
				when "Net 45"
					ship_date = (order.cancel_date + 50)
				when "Net 60"
					ship_date = (order.cancel_date + 65)
				end
				ship_date = ship_date.strftime("%d %b %Y")
			else
				case order.payment_terms
				when "Net 30"
					ship_date = "35 days after Cancel Date"
				when "Net 45"
					ship_date = "50 days after Cancel Date"
				when "Net 60"
					ship_date = "65 days after Cancel Date"
				end
			end
		end
		return ship_date
	end

	def net_terms_payment_estimate(order:)
		case order.payment_terms
		when "Net 30"
			payment = "30"
			receipt = "35"
		when "Net 45"
			payment = "45"
			receipt = "50"
		when "Net 60"
			payment = "60"
			receipt = "65"
		end
		return {receipt: receipt, payment: payment} 
	end

	def display_order_response(order:)
		case order.status
		when "submitted"
			unless order.comments.declined.present?
				text = order.comments.open.first.text
				preface = "#{order.brand_company_name} sent a comment with the order:"
			end
		when "pending"
			text = order.comments.submitted.last.text
			if order.comments.declined.present?
				preface = "#{order.orderer_company_name} has responded to your request:"
			else
				preface = "#{order.orderer_company_name} sent a comment with the order:"
			end
		end

		if text.present?
			return { preface: preface, text: text }
		else
			return false
		end

	end

end