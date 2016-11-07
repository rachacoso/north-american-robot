module OnboardHelper

	def get_onboard_stage(company:, user:)
		return company.onboard_stage(user)
	end

	def get_onboard_stage_class(current_stage:,stage:)

		if current_stage == 1
			case stage
			when 1
				return "class=active"
			else
				return nil
			end
		elsif current_stage == 2
			case stage
			when 1
				return "class=done"
			when 2
				return "class=active"
			else
				return nil
			end 
		elsif current_stage == 3
			case stage
			when 1..2
				return "class=done"
			when 3
				return "class=active"
			else
				return nil
			end
		elsif current_stage == 4
			case stage
			when 1..3
				return "class=done"
			when 4
				return "class=active"
			else
				return nil
			end
		elsif current_stage == 5
			case stage
			when 1..4
				return "class=done"
			when 5
				return "class=active"
			else
				return nil
			end
		else 
			return "class=done"
		end
		
	end


	def onboard_brand_partial(major:, minor:)
		case major
		when 1
			header = "Create A Profile"
			image_path = "/images/create_profile.png"
			case minor
			when 1
				partial_file = "brands/company_info"
				step = 1
				subheader = "Enter Company Info"
			when 2
				partial_file = "users/limited_update_form"
				locals = { user: @current_user }
				step = 2
				subheader = "Enter Contact Info"
			when 3
				partial_file = "brands/products"
				step = 3
				subheader = "Enter Products"
			end
		when 2
			header = "Ordering Requirements"
			image_path = "/images/ordering_requirements.png"
			case minor
			when 1
				partial_file = "brands/ordering_requirements"
				step = 1
				subheader = "Add Ordering Requirements"
			end

		when 3


		when 4

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