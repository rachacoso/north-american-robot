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
		when "propose"
			if stage == "propose"
				c = "active viewing"
			elsif stage == "prepare" || stage == "order"
				c = "done"
			end
		when "prepare"
			if stage == "prepare"
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
		user = @current_user.brand || @current_user.distributor
		case stage
		when 'propose'
			doc_list = [
				'Products List', 
				'FOB Pricing', 
				'Tiered Pricing Schedule'
			]
		when 'prepare'
			doc_list = [
				'Testing Information',
				'Ingredient or Materials List',
				'Patent Information',
				'Certification Information'
			]
		end
		test_count = 0
		doc_list.each do |item|
			test_count += user.library_documents.where(type: item).count > 0 ? 1 : 0
		end
		return test_count == doc_list.count ? true : false		
	end

	def check_docs(doctype)
		user = @current_user.brand || @current_user.distributor
		if user.library_documents.where(type: doctype).exists?
			return "<span data-tooltip aria-haspopup='true' class='has-tip' title='Uploaded!'><i class='fi-check' style='color: green;'></i></span>"
		else
			return "<span data-tooltip aria-haspopup='true' class='has-tip' title='Need to Upload!'><i class='fi-x' style='color: red;'></i></span>"
		end
	end

	def check_stage_proceed(match)
		if match.brand_proceed_to_next_stage
			return 'brand'
		elsif match.distributor_proceed_to_next_stage
			return 'distributor'
		else
			return false
		end
	end

	def show_proceed_stage_initial?(match)
		if match.stage == "contact"
			return match.messages.count > 1 ? true : false
		else
			return match.send("brand_shared_#{match.stage}") && match.send("distributor_shared_#{match.stage}") ? true : false
		end
	end

	def get_next_stage(match)
		case match.stage
		when 'contact'
			next_stage = 'propose'
		when 'propose'
			next_stage = 'prepare'
		when 'prepare'
			next_stage = 'order'
		end
		return next_stage.upcase
	end

	def get_sku_info(sku_id, match)
		product = match.brand.products.find(sku_id)
		return product
	end

	# def shared_indicator(item, match)
	# 	if item.kind_of?(Array)
	# 		all_shared = true
	# 		item.each do |i|
	# 			if match.send(i).blank?
	# 				all_shared = false
	# 			end
	# 		end
	# 		if all_shared
	# 			return "<i class='fi-check' style='color: green; font-size:1em;'></i>".html_safe
	# 		end
	# 	else
	# 		if !match.send(item).blank?
	# 			return "<i class='fi-check' style='color: green; font-size:1em;'></i>".html_safe
	# 		end
	# 	end
	# end

	def shared_indicator_list(display_name, item, match)
		all_shared = true
		if item.kind_of?(Array)
			item.each do |i|
				if match.send(i).blank?
					all_shared = false
				end
			end
		else
			if match.send(item).blank?
				all_shared = false
			end
		end
		if all_shared
			return "<span class='shared-indicator-bullet'><i class='fi-check' style='color: green; font-size:1em;'></i></span> <span style='color: #b2b2b2;'>#{display_name}</span></br>".html_safe
		else
			return "<span class='shared-indicator-bullet'>&bull;</span> #{display_name}<br>".html_safe
		end
	end


end
