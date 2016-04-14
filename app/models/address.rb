class Address
	require 'carmen'
	include Carmen
  include Mongoid::Document
  field :address1, type: String
  field :address2, type: String
  field :city, type: String
  field :state, type: String
  field :postcode, type: String
  field :country, type: String

  embedded_in :addressable, polymorphic: true
  
	def in_us
		if self.country.present?
			us = Country.named('United States')
			country = Country.named(self.country)
			if country == us
				return true
			end
		end
	end
	def state_2_test
		if self.state.present?
			if self.in_us
				us = Country.named(self.country)
				if state = us.subregions.coded(self.state) || state = us.subregions.named(self.state)
					return state.code
				end
			end
		end
	end
	def state_2
		if self.state.present?
			if self.in_us
				us = Country.named(self.country)
				if state = us.subregions.coded(self.state) || state = us.subregions.named(self.state)
					return state.code
				end
			else
				return self.state
			end
		end
	end
	def country_2
		if country = Country.named(self.country)
			return country.alpha_2_code
		end
	end

end
