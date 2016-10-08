class Retailer
  include Mongoid::Document
  include Mongoid::Timestamps::Short
	include Mongoid::Paperclip
	include LandingArmorPayments::Company
	include CompanyCommons::BuyersAndSellers
	include CompanyCommons::BuyersOnly

  #####################
	### Profile
	#####################

	# RETAILER STORY
	field :number_of_locations, type: Integer
	field :number_of_brands_sold, type: Integer
	# Countries of Operation
	embeds_many :export_countries, as: :exportable, store_as: "countries_of_operation", cascade_callbacks: true


	has_many :matches do 
		def contacted_by_me
			where(initial_contact_by: "retailer")
		end
		def contacting_me
			where(initial_contact_by: "brand")
		end
		def contacted_by_me_waiting
			where(initial_contact_by: "retailer", accepted: false)
		end
		def contacting_me_waiting
			where(initial_contact_by: "brand", accepted: false)
		end				
		def contacted_by_me_accepted
			where(initial_contact_by: "retailer", accepted: true)
		end
		def contacting_me_accepted
			where(initial_contact_by: "brand", accepted: true)
		end		
		def accepted
			where(accepted: true)
		end	
	end



	################
	# MODEL METHODS
	################
		
	def set_sectors(sec)

	  assigned_sectors = Sector.find(sec.values) rescue []
	  unless assigned_sectors.blank?
	    self.sectors = [] # clear current ones before update
	  end
	  assigned_sectors.each do |s|
	    self.sectors << s
	  end

	end

	def set_subsectors(ssec)

		assigned_subsectors = Subsector.find(ssec.values) rescue []
		subsector_parents = assigned_subsectors.map { |s| s.sector }

		self.subsectors = [] # clear current ones before update
		assigned_subsectors.each do |s|
		  self.subsectors << s
		end

		subsector_parents.each do |p|
		  self.sectors << p
		end

	end

	def onboard_stage(user)

		if 
			self.address.address1.blank? ||
			self.address.city.blank? || 
			self.address.postcode.blank? || 
			self.address.country.blank? || 
			self.company_name.blank? || 
			self.country_of_origin.blank? || 
			self.year_established.blank? ||
			self.company_size.blank? ||
			self.website.blank? ||
			user.contact.firstname.blank? ||
			user.contact.lastname.blank? ||
			user.contact.phone.blank?
				return 1
		else
			return 2
		end

	end

end
