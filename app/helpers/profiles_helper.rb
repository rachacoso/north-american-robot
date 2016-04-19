module ProfilesHelper

	def get_links(profile)
		links = []
		unless profile.website.blank? 
			website = link_to 'Website', "//#{clean_url(profile.website)}", target: 'blank', class: 'profile-social-link'
			links << website
		end 

		unless profile.facebook.blank? 
		 fb = link_to 'Facebook', "//#{clean_url(profile.facebook)}", target: 'blank', class: 'profile-social-link'
		 links << fb
		end 

		unless profile.linkedin.blank? 
		 li = link_to 'LinkedIn', "//#{clean_url(profile.linkedin)}", target: 'blank', class: 'profile-social-link'
		 links << li
		end 

		unless profile.twitter.blank? 
		 twt = link_to 'Twitter', "//#{clean_url(profile.twitter)}", target: 'blank', class: 'profile-social-link'
		 links << twt
		end 

		unless profile.instagram.blank? 
		 ig = link_to 'Instagram', "//#{clean_url(profile.instagram)}", target: 'blank', class: 'profile-social-link'
		 links << ig
		end

		return links
	end

	def profile_status(order)
		case order.status
		when "open"
			if !@current_user.brand
				return "You have an OPEN order"
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
				return "Order awaiting Payment and Shipping information"
			else
				return "Order awaing Payment and Shipping information from #{order.orderer.company_name}"
			end
		end
	end

end