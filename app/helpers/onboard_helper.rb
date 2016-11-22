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
			when current_stage.to_i > stage.to_i
				return "class=done"
			when current_stage.to_i == stage.to_i
				return "class=active"
			when current_stage.to_i < stage.to_i
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
			partial_file = ["brands/company_info"]
			subheader = "Enter Company Info"
		when 2
			header = "Create A Profile"
			image_path = "/images/create_profile.png"
			partial_file = ["users/limited_update_form"]
			locals = [{ user: @current_user }]
			subheader = "Enter Contact Info"
		when 3
			header = "Create A Profile"
			image_path = "/images/create_profile.png"
			partial_file = ["brands/products"]
			subheader = "Enter Products"
		when 4
			header = "Ordering Requirements"
			image_path = "/images/ordering_requirements.png"
			partial_file = ["brands/ordering_requirements"]
			subheader = "Add Ordering Requirements"
		when 5
			header = "Brand Story"
			image_path = "/images/talk_details.png"
			partial_file = ["brands/company_introduction"]
			subheader = "Tell Your Story"
		when 6
			header = "Brand Photos"
			image_path = "/images/talk_details.png"
			partial_file = ["brands/brand_photos"]
			subheader = "Show Us Your Stuff"
		when 7
			header = "Trends"
			image_path = "/images/talk_details.png"
			partial_file = ["brands/trends"]
			subheader = ""
		when 8
			header = "Global Good"
			image_path = "/images/talk_details.png"
			partial_file = ["brands/social_tags"]
			subheader = ""
		when 9
			header = "Key Retailers"
			image_path = "/images/boost_profile.png"
			partial_file = ["brands/key_retailers"]
			subheader = ""
		when 10
			header = "Sectors"
			image_path = "/images/boost_profile.png"
			partial_file = ["brands/sectors"]
			subheader = ""
		when 11
			header = "Channels"
			image_path = "/images/boost_profile.png"
			partial_file = ["brands/channels"]
			subheader = ""
		when 12
			header = "Channel Capacities"
			image_path = "/images/boost_profile.png"
			partial_file = ["brands/channel_capacities"]
			subheader = ""
		when 13
			header = "Countries of Distribution"
			image_path = "/images/boost_profile.png"
			partial_file = ["brands/countries_of_distribution"]
			subheader = ""
		when 14
			header = "Press Hits"
			image_path = "/images/show_off.png"
			partial_file = ["brands/press_hits"]
			subheader = ""
		when 15
			header = "Trade Shows"
			image_path = "/images/show_off.png"
			partial_file = ["brands/trade_shows"]
			subheader = ""
		when 16
			header = "Patents"
			image_path = "/images/show_off.png"
			partial_file = ["brands/patents"]
			subheader = ""
		when 17
			header = "Trademarks"
			image_path = "/images/show_off.png"
			partial_file = ["brands/trademarks"]
			subheader = ""
		when 18
			header = "Certifications / Regulatory Compliance"
			image_path = "/images/show_off.png"
			partial_file = ["brands/business_certifications"]
			subheader = ""
		when 19
			header = "Social Ethos and Impact"
			image_path = "/images/show_off.png"
			partial_file = ["brands/social_fields"]
			subheader = ""
		end

		partial = Hash.new
		partial[:file] = partial_file
		partial[:locals] = locals.present? ? locals : nil
		# partial[:step] = step
		partial[:image_path] = image_path
		partial[:header] = header
		partial[:subheader] = subheader
		return partial

	end


end