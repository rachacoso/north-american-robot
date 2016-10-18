class OnboardController < ApplicationController

	before_action :get_info, only: [:show]

	def show

	end

	private
	def get_info
		@company = @current_user.company
		@type = @current_user.type?
	end

end