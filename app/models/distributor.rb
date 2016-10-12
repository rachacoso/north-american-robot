class Distributor
  include Mongoid::Document
  include Mongoid::Timestamps::Short
	include Mongoid::Paperclip
	include LandingArmorPayments::Company
	include LandingCompany::BuyersAndSellers
	include LandingCompany::Buyers
	include LandingCompany::OrderTermsAndRequirements
	include LandingCompany::OrderTermsAndRequirements::BuyerValidation

 	#####################
	### Profile
	#####################

	# DISTRIBUTOR STORY
	field :rating, type: Integer, default: 0 # validation rating 0-7 based on validation criterion
	has_and_belongs_to_many :channels, inverse_of: nil 
	has_many :channel_capacities, dependent: :destroy

	# Countries of Distribution
	embeds_many :export_countries, as: :exportable

	# Current/Past Portfolio
	has_many :distributor_brands, dependent: :destroy

	# Sales/Education Capabilities
	field :outside_sales_size, type: Integer
	field :inside_sales_size, type: Integer


	# array of saved brand matches
	has_and_belongs_to_many :saved_matches, class_name: "Brand", inverse_of: nil

	has_many :matches do 
		def contacted_by_me
			where(initial_contact_by: "distributor")
		end
		def contacting_me
			where(initial_contact_by: "brand")
		end
		def contacted_by_me_waiting
			where(initial_contact_by: "distributor", accepted: false)
		end
		def contacting_me_waiting
			where(initial_contact_by: "brand", accepted: false)
		end				
		def contacted_by_me_accepted
			where(initial_contact_by: "distributor", accepted: true)
		end
		def contacting_me_accepted
			where(initial_contact_by: "brand", accepted: true)
		end		
		def accepted
			where(accepted: true)
		end	
	end

	# document library
	has_many :library_documents, as: :documentable, dependent: :destroy


################
# MODEL METHODS
################

	def completeness_percentage

		# items to test for nil (i.e. field does not exist yet)
		# these can be blank and still count towards full profile 
		# (i.e. as long as user has visited a page where they can update these items)
		items_nil = [
			:outside_sales_size,
			:inside_sales_size,
			:internal_marketing_size,
			:employ_pr_agency,
			:marketing_via_print,
			:marketing_via_online,
			:marketing_via_email,
			:marketing_via_outdoor,
			:marketing_via_events,
			:marketing_via_direct_mail,
			:marketing_via_classes,
			:customer_database_size
		]

		# items to test for present-ness (i.e. field exists AND has content)
		items_present = [
		 	:company_name,
			:country_of_origin,
			:year_established,
			:company_size,
			:website,
			:logo_file_name,			
		 	:export_countries,
		 	:sectors,
		 	:channels,
		 	:distributor_brands,
		 	:trade_shows
		]

		items_passed = 0

		puts "xxxxxxx"

		# check social media (only need one)
		if self.facebook.present? || self.linkedin.present?
			items_passed += 1
		end

		# check channel capacities (all must be complete)
		cc_incomplete = self.channel_capacities.where(capacity: nil).count
		puts "incomplete channel capacities: #{cc_incomplete}"
		unless cc_incomplete > 0
			items_passed += 1
		end

		# NIL test
		items_nil.each do |item|
			if !self.send(item).nil?
				items_passed += 1
				puts "#{item} YES"
			else
				puts "#{item} NO"
			end
		end

		# PRESENT test
		items_present.each do |item|
			if self.send(item).present?
				items_passed += 1
				puts "#{item} YES"
			else
				puts "#{item} NO"
			end
		end
		puts "yyyyyyyy"
		
		total_items = items_nil.count + items_present.count + 2 # add 1 for SOCIAL MEDIA test and 1 for CHANNEL CAPACITIES test

		total_percent = (items_passed.to_f / total_items) * 100
		puts total_percent

		return total_percent.round
		
	end

	def update_completeness

		percent = self.completeness_percentage
		case percent
		when 50..75
			completeness_level = 1
		when 75..99
			completeness_level = 2
		when 100..(1.0/0.0)
			completeness_level = 3
		else
			completeness_level = 0
		end
		self.completeness = completeness_level
		self.save

	end

	def onboard_stage

		if 
			self.address.blank? || 
			self.company_name.blank? || 
			self.country_of_origin.blank? || 
			self.year_established.blank? ||
			self.company_size.blank? ||
			self.website.blank? ||
			self.contacts.blank? ||
			self.products.blank?
				return 1
		else
			return 2
		end

	end

end
