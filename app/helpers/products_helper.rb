module ProductsHelper

	def display_price(price)
		return '%.2f' % (price.to_f / 100)
	end

end
