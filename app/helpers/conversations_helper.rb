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

	def has_all_docs(stage)
		case stage
		when 'contact'
			user = @current_user.brand
			doc_list = [
				'Products List', 
				'FOB Pricing', 
				'Tiered Pricing Schedule'
			]
			test_count = 0
			doc_list.each do |item|
				test_count += user.library_documents.where(type: item).count > 0 ? 1 : 0
			end
			return test_count == doc_list.count ? true : false
		end
	end

	def check_docs(doctype)
		user = @current_user.brand || @current_user.distributor
		if user.library_documents.where(type: doctype).exists?
			return "<span data-tooltip aria-haspopup='true' class='has-tip' title='Uploaded!'><i class='fi-check' style='color: green;'></i></span>"
		else
			return "<span data-tooltip aria-haspopup='true' class='has-tip' title='Need to Upload!'><i class='fi-x' style='color: red;'></i></span>"
		end
	end

end
