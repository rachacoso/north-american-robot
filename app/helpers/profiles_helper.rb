module ProfilesHelper

	def show_links(profile)
		links = []

		unless profile.facebook.blank?
			fb = "<a href='//#{clean_url(profile.facebook)}' target='blank' class='profile-social-link'><img src='https://s3.amazonaws.com/landingintl-us/general/facebook-icon.png' width='30'></a>"
			links << fb
		end 

		unless profile.linkedin.blank?
			li = "<a href='//#{clean_url(profile.linkedin)}' target='blank' class='profile-social-link'><img src='https://s3.amazonaws.com/landingintl-us/general/linkedin-icon.png' width='30'></a>"
			links << li
		end 

		unless profile.twitter.blank?
			twt = "<a href='//#{clean_url(profile.twitter)}' target='blank' class='profile-social-link'><img src='https://s3.amazonaws.com/landingintl-us/general/twitter-icon.png' width='30'></a>"
			links << twt
		end 

		unless profile.instagram.blank?
			ig = "<a href='//#{clean_url(profile.instagram)}' target='blank' class='profile-social-link'><img src='https://s3.amazonaws.com/landingintl-us/general/instagram-icon.png' width='30'></a>"
			links << ig
		end
		unless links.blank?
			return "<div class='profile-general-info-item'><div class='title'>Social:</div>#{links.join(' ')}</div>".html_safe
		end
	end

	def show_global_good_tags(profile)
		tags = ""
		unless profile.tags.blank?
			profile.tags.each do |tag|
				tags += "<span class='profile-tag'>#{tag.name}</span>"
			end
			return "<div class='profile-general-info-item'><div class='title'>Global Good Tags:</div>#{tags.html_safe}</div>".html_safe
		end
	end

	def show_trend_tags(profile)
		tags = ""
		unless profile.trends.blank?
			profile.trends.pluck(:name).each do |trend|
				tags += "<span class='profile-tag'>#{trend}</span>"
			end
			return "<div class='profile-general-info-item'><div class='title'>Trend Tags:</div>#{tags}</div>".html_safe
		end
	end

	def show_website_url(profile)
		unless profile.website.blank? 
			link = link_to "#{clean_url(profile.website)}", "//#{clean_url(profile.website)}", target: 'blank', class: 'profile-social-link'
			return "<div class='profile-general-info-item'><div class='title'>Website:</div>#{link}</div>".html_safe
		end

	end

	def show_country_of_origin(profile)
		if profile.country_of_origin.blank?
			item = "n/a"
		else
			item = profile.country_of_origin
		end
		return "<div class='profile-general-info-item'><div class='title'>Country of Origin:</div>#{item}</div>".html_safe
	end

	def show_company_size(profile)
		if profile.company_size.blank?
			item = "n/a"
		else
			item = CompanySize.find(profile.company_size).name rescue nil
		end
		return "<div class='profile-general-info-item'><div class='title'>Company Size:</div>#{item}</div>".html_safe
	end

	def show_sectors(profile)
		if profile.sectors.blank? 
			item = "n/a"
		else 
			profile.sectors.order_by(:name => "asc").each do |s| 
				sector = ""
				sector += s.name 
				unless profile.subsectors.where(:sector => s).blank? 
					sector += " (#{profile.subsectors.where(:sector => s).pluck(:name).to_a.join(", ")})"
				end 
				item = sector
			end 
		end
		return "<div class='profile-general-info-item'><div class='title'>Sectors:</div>#{item}</div>".html_safe
	end

	def show_channels(profile)
		unless profile.channels.blank?
			channels = []
			custom_channels = []
			all_channels = ""
			profile.channels.each do |ch| 
				if !profile.channel_capacities.where(channel_id: ch.id).first.capacity.blank?
					capacity = profile.channel_capacities.where(channel_id: ch.id).first.capacity
					channels << "#{ch.name} (#{capacity})"
				else
					channels << "#{ch.name}"
				end
			end 
			if profile.channel_capacities.where(channel_id: 0).length > 0 
				profile.channel_capacities.where(channel_id: 0).each do |cch| 
					custom_channels << "#{cch.custom_channel_name} #{cch.capacity.blank? ? '' : '(' + cch.capacity.to_s + ')'}"
				end
			end
			all_channels += "<div class='profile-general-info-item'><div class='title'>Channels (capacity):</div>#{channels.join('<br>')}</div>"
			all_channels += "<div class='profile-general-info-item'><div class='title'>Custom Channels (capacity):</div>#{custom_channels.join('<br>')}</div>"
			return all_channels.html_safe
		end
	end

	def show_countries_of_distribution(profile) # distributor
		unless profile.export_countries.blank?
			item = profile.export_countries.pluck(:country).join(", ")
			return "<div class='profile-general-info-item'><div class='title'>Countries of Distribution:</div>#{item}</div>".html_safe
		end
	end

	def show_countries_of_operation(profile) # retailer
		unless profile.export_countries.blank?
			item = profile.export_countries.pluck(:country).join(", ")
			return "<div class='profile-general-info-item'><div class='title'>Countries of Operation:</div>#{item}</div>".html_safe
		end
	end

	def show_number_of_locations(profile)
		if profile.number_of_locations.blank?
			item = "n/a"
		else
			item = profile.number_of_locations
		end
		return "<div class='profile-general-info-item'><div class='title'>Number of Locations:</div>#{item}</div>".html_safe
	end

	def show_number_of_brands_sold(profile)
		if profile.number_of_brands_sold.blank?
			item = "n/a"
		else
			item = profile.number_of_brands_sold
		end
		return "<div class='profile-general-info-item'><div class='title'>Number of Brands Sold:</div>#{item}</div>".html_safe
	end

	def profile_status(order)
		case order.status
		when "open"
			if !@current_user.brand
				return "You have an open order"
			else
				return "#{order.orderer.company_name} has an open order"
			end
		when "submitted"
			if !@current_user.brand
				return "You have submitted an order"
			else
				return "#{order.orderer.company_name} has submitted an order"
			end
		when "pending"
			if !@current_user.brand
				return "Order awaiting your approval"
			else
				return "Order awaing approval by #{order.orderer.company_name}"
			end
		when "approved"
			if !@current_user.brand
				return "Order awaiting your transfer of payment to escrow"
			else
				return "Order awaing payment transfer to escrow by #{order.orderer.company_name}"
			end
		when "paid"
			if !@current_user.brand
				return "Order paid and awaiting shipment by #{order.brand.company_name}"
			else
				return "Order paid. Please ship the order to #{order.orderer.company_name}"
			end
		when "shipped"
			if !@current_user.brand
				return "Order has been shipped"
			else
				return "Order has been shipped"
			end
		when "delivered"
			if !@current_user.brand
				return "Order has been delivered and is awaiting your review & payment release"
			else
				return "Order has been delivered and is awaiting review & payment release"
			end
		when "completed"
			if !@current_user.brand
				return "Order has been delivered, payment released and is now complete"
			else
				return "Order has been delivered, payment released and is now complete"
			end
		end
	end


	def show_logo(profile)

		if profile.logo_file_name
			return image_tag profile.logo.url(:medium), alt: "Logo", id: "logo"
		else
			if !profile.facebook.blank? && fb_picture(profile.facebook)
				return image_tag fb_picture(profile.facebook), id: "logo"
			else
				return image_tag profile.logo.url(:medium), width: "100", height: "100", alt: "Logo", id: "logo"
			end
		end

	end


end