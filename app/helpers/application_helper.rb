module ApplicationHelper

	def get_collection_variables(newitem, iscurrent)

		collection_name = newitem.class.name.tableize

		case iscurrent
		when "true"
			form_id = "new_current_" + newitem.class.name.tableize
		when "false"
			form_id = "new_past_" + newitem.class.name.tableize
		else
			form_id = "new_" + newitem.class.name.tableize
		end

		return form_id, collection_name

	end

	def check_brand_public_profile # check "completeness" of public profile

		list = 0

		# fields to check from primary document
		checklist = [
			:year_established,
			:company_size,
			:country_of_origin,
			:export_countries,
			:sectors,
			:channels
		]
		
		# fields to check from related document (:country_of_manufacture in :products)
		if @profile.products.distinct(:country_of_manufacture).reject(&:empty?).count > 0
				list += 1
		end

		# complete is all from checklist plus the related document(s)
		complete = checklist.count + 1

		checklist.each do |item|
			if !@profile.send(item).blank?
				list += 1
			end
		end

		percent_complete = list.to_f/complete.to_f * 100.0

		return percent_complete.round

	end

	def check_brand_full_profile(profile) # check "completeness" of full profile

		# NEED TO do

		return profile.completeness_percentage

	end



	def check_distributor_public_profile # check "completeness" of public profile

		list = 0

		# fields to check from primary document
		checklist = [
			:year_established,
			:company_size,
			:country_of_origin,
			:sectors,
			:channels
		]

		# complete is all from checklist
		complete = checklist.count

		checklist.each do |item|
			if !@profile.send(item).blank?
				list += 1
			end
		end

		percent_complete = list.to_f/complete.to_f * 100.0

		return percent_complete.round

	end

	def check_distributor_full_profile(profile) # check "completeness" of full profile

		return profile.completeness_percentage

	end

	def show_top_menu # check if should show the top menu (i.e. don't show if in onboard controller)
		if controller_name == "onboard_brand" || controller_name == "onboard_distributor"
			return false
		else 
			return true
		end
	end

	#check to see if the collection includes pictures (so can render appropriate forms inputs)
	def has_picture_list(collection)
		list = [	'product',
							'distributor_brand'	]
		if list.include?(collection.class.name.tableize.singularize)
			return true
		else
			return false
		end
	end

	def collection_item_active(cid = nil)
		if flash[:make_active] == cid.to_s
			return "active"
		else
			return nil
		end
	end

	# check if filter checkbox should be on or off (based on what was selected on prior searches)
	def filter_on_or_off(item, checklist)
		if checklist && checklist.include?(item)
			return true
		else
			return false
		end
	end

	# Getting and determining direction of  matches
	def this_match(profile)
		if @current_user.distributor
			return @current_user.distributor.matches.where(brand_id: profile.id).first
		elsif @current_user.brand
			return @current_user.brand.matches.where(distributor_id: profile.id).first
		end
	end

	def i_contacted(match)
		if match.initial_contact_by == @current_user.type?
			return true
		else
			return false
		end
	end

	# Messages Helpers
	# Mark messages as read
	def mark_as_read(message)
		if !message.read && message.recipient == @current_user.type?	
			message.read = true
			message.save!
		end
	end


	# Get # of unread messages

	def unread_count_from_messages(messages)
		messages.where(read: false, recipient: @current_user.type?).count
	end

	def unread_count_from_match(match)
		if @current_user.type? == "distributor"
			if k = match.matches.where(distributor_id: @current_user.distributor.id).first
				# k.messages.where(read: false, recipient: "distributor").count
				count = unread_count_from_messages(k.messages)
			end
		else
			if k = match.matches.where(brand_id: @current_user.brand.id).first
				# k.messages.where(read: false, recipient: "brand").count
				count = unread_count_from_messages(k.messages)
			end
		end
		if count && count > 0
			return true, count
		else 
			return false
		end
	end

	# Last Activity Indicator
	def last_activity(last_login)
			if (1.day.ago..Time.now).cover?(last_login)
				return "day"
			elsif (1.week.ago..Time.now).cover?(last_login)
				return "week"
			elsif (1.month.ago..Time.now).cover?(last_login)
				return "month"
			elsif (1.year.ago..Time.now).cover?(last_login)
				return "year"
			else
				return "decade"
			end
	end

	# GET PROFILE INFORMATION FOR MATCHES
	def get_profile_info_brand(m)
		size = CompanySize.find(m.company_size).name
		sectors = Sector.find(m.sector_ids)
		channels = Channel.find(m.channel_ids)
		return size, sectors, channels
	end
	def get_profile_info_distributor(m)
		size = CompanySize.find(m.company_size).name
		channels = Channel.find(m.channel_ids)
		return size, channels
	end

	# CLEAN URLS

	def clean_url(url)
		return url.sub(/^https?\:\/\//, '').sub(/^www./,'')
	end

	# GET FACEBOOK ID / PROFILE PICTURE

	def fb_picture(profile_url)

		if /facebook.com\/pages\//.match(profile_url) # is a page, not a person, REJECT
			return false
		else
			if facebook_id = profile_url[/facebook.com\/([a-z,A-Z,0-9,-,\.]+)\??\/?.*$/,1]
			# facebook_id = /facebook.com\/([^\/\?]+)\/?.*\z/.match(profile_url)[1]
				return "//graph.facebook.com/#{facebook_id.strip}/picture"
			else
				return false
			end
		end

	end

	def armor_lightbox_script
		if Rails.env.production?
			return "<script src='https://app.armorpayments.com/static/external/js/lightbox-ui.min.js' type='text/javascript'></script>".html_safe
		else
			return "<script src='https://sandbox.armorpayments.com/static/external/js/lightbox-ui.min.js' type='text/javascript'></script>".html_safe
		end
	end

	def dollarize(amount)
		return amount / 100
	end

end