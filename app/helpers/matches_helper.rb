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

	def get_last_login(match)

		login_list = Array.new
		match.users.each do |user|
			login_list << user.last_login
		end

		return login_list.sort!.first

	end

end
