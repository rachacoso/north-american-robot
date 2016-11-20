module OnboardHelper

	def get_onboard_stage(company:, user:, stage: nil)
		proper_stage = company.onboard_stage(user)
		if stage && stage.to_i < proper_stage.to_i
			return stage.to_i
		else
			return proper_stage
		end
	end

	def get_onboard_stage_class(current_stage:,stage_group: nil,stage: nil)

		if stage
			case 
			when current_stage.to_i < stage.to_i
				return "class=done"
			when current_stage.to_i == stage.to_i
				return "class=active"
			when current_stage.to_i > stage.to_i
				return nil
			end
		end

		if stage_group
			if stage_group.include? current_stage
				return "class=active"
			elsif stage_group.first.to_i < current_stage.to_i
				return "class=done"
			elsif stage_group.last.to_i > current_stage.to_i
				return nil
			end
		end
		
	end


	def onboard_brand_partial(stage:)
		case stage
		when 1
			header = "Create A Profile"
			image_path = "/images/create_profile.png"
			partial_file = "brands/company_info"
			step = 1
			subheader = "Enter Company Info"
		when 2
			header = "Create A Profile"
			image_path = "/images/create_profile.png"
			partial_file = "users/limited_update_form"
			locals = { user: @current_user }
			step = 2
			subheader = "Enter Contact Info"
		when 3
			header = "Create A Profile"
			image_path = "/images/create_profile.png"
			partial_file = "brands/products"
			step = 3
			subheader = "Enter Products"
		when 4
			header = "Ordering Requirements"
			image_path = "/images/ordering_requirements.png"
			partial_file = "brands/ordering_requirements"
			step = 1
			subheader = "Add Ordering Requirements"
		when 5

		end

		partial = Hash.new
		partial[:file] = partial_file
		partial[:locals] = locals.present? ? locals : nil
		partial[:step] = step
		partial[:image_path] = image_path
		partial[:header] = header
		partial[:subheader] = subheader
		return partial

	end


end