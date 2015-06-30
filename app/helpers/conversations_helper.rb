module ConversationsHelper


	def contact_stage_indicator (match, div)
		stage = match.stage
		case div
		when "contact"
			if stage == "contact"
				c = "active viewing"
			else 
				c = "done"
			end
		when "prepare"
			if stage == "prepare"
				c = "active viewing"
			elsif stage == "terms" || stage == "order"
				c = "done"
			end
		when "terms"
			if stage == "terms"
				c = "active viewing"
			elsif stage == "order"
				c = "done"
			end
		when "order"
			if stage == "order"
				c = "active viewing end"
			end
		end

		c = "convo-map " + c.to_s
		return c

	end	

end
