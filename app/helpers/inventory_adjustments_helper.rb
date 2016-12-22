module InventoryAdjustmentsHelper
	def label_text(adjustment)
		text = adjustment.units.to_s + " units"
		text += "<div style='font-size:12px;line-height:14px;'>" 
		text += "#{ simple_format(adjustment.comment,{ }, wrapper_tag: 'span') }"
		text += "<br>requested on #{adjustment.c_at.in_time_zone("Pacific Time (US & Canada)").strftime('%B %d, %Y at %H:%M:%S %Z')}"
		text += "</div>"
		return text
	end
end