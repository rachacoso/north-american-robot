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