module ArticlesHelper

	def get_article_type(type)
		case type
		when 1
			return "BRANDS"
		when 2
			return "TRENDS"
		end
	end
	
end