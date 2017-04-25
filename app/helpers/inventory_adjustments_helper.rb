module InventoryAdjustmentsHelper
	def label_text(adjustment)
		text = adjustment.units.to_s + " units"
		text += "<div style='font-size:12px;line-height:14px;'>" 
		text += "#{ simple_format(adjustment.comment,{ }, wrapper_tag: 'span') }"
		text += "<br>requested on #{adjustment.c_at.in_time_zone("Pacific Time (US & Canada)").strftime('%B %d, %Y at %H:%M:%S %Z')}"
		text += "</div>"
		return text
	end
	def inventory_adjustment_mailer_display(adjustment:, update_date: nil, updated: nil, previous_data: nil)
		if previous_data.present?
			comment = previous_data[:comment]
			associated_shipments = previous_data[:associated_shipments]
			associated_requests = previous_data[:associated_requests]
			units = previous_data[:units]
			update_date = nil
		else
			comment = adjustment.comment
			associated_shipments = adjustment.associated_shipments
			associated_requests = adjustment.associated_requests
			units = adjustment.units
			if updated
				update_date = adjustment.u_at
			else
				update_date = nil
			end
		end
		locals = {
			previous_data: previous_data,
			update_date: update_date,
			adjustment_date: adjustment.c_at,
			ship_date: adjustment.ship_date,
			product: adjustment.product, 
			units: units, 
			associated_shipments: associated_shipments,
			associated_requests: associated_requests,
			comment: comment
		} 
		return render partial: "inventory_adjustment_display", locals: locals
	end

	def get_combined_entries(product)
		holds = product.brand.orders.with_inventory_hold(product).entries
		deductions = product.brand.orders.with_inventory_deductions(product).entries
		adjustments = product.inventory_adjustments.entries
		combined = holds + deductions + adjustments
		return combined.sort_by! { |a| a.class.to_s == "Order" ? ( Order.with_inventory_deductions(product).include?(a) ? (a.inventory_deduction_date.blank? ? a.delivered_date : a.inventory_deduction_date ) : a.pending_date_array.last) : a.c_at }.reverse
	end

end