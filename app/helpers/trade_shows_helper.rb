module TradeShowsHelper

	def get_tradeshow_display_info(show)
		ts = []
		unless show.country.blank?
			ts << "<strong>#{show.country}</strong>"
		end
		if show.date
			ts << "#{show.date.strftime('%b %Y')}"
		end
		unless show.years_participated.blank?
			ts << "Participant for #{show.years_participated} years"
		end
		return ts
	end
end
