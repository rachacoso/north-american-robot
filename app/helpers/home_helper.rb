module HomeHelper

	def get_share_type(id)
		if Brand.find(id)
			return 'brand'
		elsif Distributor.find(id)
			return 'distributor'
		else
			return nil
		end
	end
	
end
