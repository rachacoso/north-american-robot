module MatchesHelper

	def get_last_login(match)

		login_list = Array.new
		match.users.each do |user|
			login_list << user.last_login
		end

		return login_list.sort!.first

	end

end
