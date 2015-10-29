module MatchesHelper


	def get_conversation_stage(match)
		# stage = match.stage
		# stage ||= 'contact'
		return match.stage
	end

	def get_match(profile)
		b_or_d = @current_user.send(@current_user.type?)
		if @current_user.type? == 'brand'
			if this_match = @current_user.send(@current_user.type?).matches.where(distributor_id: profile.id).first
				return this_match
			else
				return false
			end
		elsif @current_user.type? == 'distributor'
			if this_match = @current_user.send(@current_user.type?).matches.where(brand_id: profile.id).first
				return this_match
			else
				return false
			end
		end
	end


	def get_photos(profile)
		b_photos = Array.new
		profile.brand_photos.each do |item|
			b_photos << item
		end

		p_photos = Array.new
		profile.products.each do |product|
			product.product_photos.each do |photo|
				p_photos << photo
			end
		end

		photos = Array.new
		photos = b_photos.shuffle[0..7] + p_photos.shuffle[0..7]
		return photos.shuffle
	end


	def get_last_login(match)

		login_list = Array.new
		match.users.each do |user|
			if user.last_login
				login_list << user.last_login
			end
		end
		return login_list.sort!.last

	end

end
