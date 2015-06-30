module ConversationsHelper


	def contact_stage_indicator (match, div)
		stage = match.stage
		case div
		when "contact"
			if stage == "contact"
				c = "active"
			else 
				c = "done"
			end
		when "prepare"
			if stage == "prepare"
				c = "active"
			elsif stage == "terms" || stage == "order"
				c = "done"
			end
		when "terms"
			if stage == "terms"
				c = "active"
			elsif stage == "order"
				c = "done"
			end
		when "order"
			if stage == "order"
				c = "active"
			end
		end

		c = "convo-map " + c.to_s
		return c

	end	

end
