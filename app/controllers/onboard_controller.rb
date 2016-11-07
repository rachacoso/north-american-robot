class OnboardController < ApplicationController

	before_action :get_info, only: [:show]

	def show

		if params[:next]
			@next = true
		end
		
		case @type
		when 'brand'
			@brand = @company

			# if @brand.armor_account_id && @brand.users.with_armor_user_id.present?
			# 	url = @brand.api_get_bank_account_setup_url(armor_account_id: @brand.armor_account_id, armor_user_id: @brand.users.with_armor_user_id.first.armor_user_id)
			# 	unless @brand.errors.any?
			# 		@armor_bank_url = url
			# 	end
			# end

			@current_products = @brand.products.where(current: true) rescue nil
			@past_products = @brand.products.where(current: false) rescue nil
			@new_product = Product.new
			
			@trade_shows = @brand.trade_shows rescue nil
			@new_trade_show = TradeShow.new

			@press_hits = @brand.press_hits rescue nil
			@new_press_hit = PressHit.new

			@patents = @brand.patents rescue nil
			@new_patent = Patent.new

			@trademarks = @brand.trademarks rescue nil
			@new_trademark = Trademark.new

			@compliances = @brand.compliances rescue nil
			@new_compliance = Compliance.new

			@channel_capacities = @brand.channel_capacities rescue nil
			@new_channel_capacity = ChannelCapacity.new

			@export_countries = @brand.export_countries rescue nil
			@new_export_country = ExportCountry.new				

			#FOR TAGS
			@tags = @brand.tags rescue nil

			# BUILD 'PRODUCT_TAGS' HASH WITH PRODUCT'S TAGS
			@product_tags = Hash.new
			@brand.products.each do |product|
				@product_tags[product.id] = product.tags
			end

		when 'retailer'
			@retailer = @company
		when 'distributor'
			@distributor = @company
		end
		
	end

	private
	def get_info
		@company = @current_user.company
		@type = @current_user.type?
	end

end