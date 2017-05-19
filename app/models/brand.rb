class Brand
  include Mongoid::Document
  include Mongoid::Timestamps::Short
	include Mongoid::Paperclip
	include LandingArmorPayments::Company
	include LandingCompany::Sellers
	include LandingCompany::BuyersAndSellers

	before_create { set_subscriber_account_number }

  #####################
	### Profile
	#####################
	field :subscriber_account_number, type: Integer
	# BRAND STORY
	field :brand_positioning, type: String # now referenced as "company introduction" in ui

	has_and_belongs_to_many :channels, inverse_of: nil 
	has_many :channel_capacities, dependent: :destroy
	has_and_belongs_to_many :key_retailers, inverse_of: nil
	has_and_belongs_to_many :trends, inverse_of: nil

	has_many :brand_photos, dependent: :destroy
	has_many :library_documents, as: :documentable, dependent: :destroy

	# Current/Future SKUs
	has_many :products, dependent: :destroy

	# Marketing Acivities
	has_many :press_hits, dependent: :destroy

	# REGULATORY
	has_many :patents, dependent: :destroy
	has_many :trademarks, dependent: :destroy
	has_many :compliances, dependent: :destroy

	# EXPORT COUNTRIES
	embeds_many :export_countries, as: :exportable, cascade_callbacks: true



	# array of saved distributor matches
	has_and_belongs_to_many :saved_matches, class_name: "Distributor", inverse_of: nil

	has_many :matches do 
		def contacted_by_me
			where(initial_contact_by: "brand")
		end
		def contacting_me
			where(initial_contact_by: "distributor")
		end
		def contacted_by_me_waiting
			where(initial_contact_by: "brand", accepted: false)
		end
		def contacting_me_waiting
			where(initial_contact_by: "distributor", accepted: false)
		end			
		def contacted_by_me_accepted
			where(initial_contact_by: "brand", accepted: true)
		end
		def contacting_me_accepted
			where(initial_contact_by: "distributor", accepted: true)
		end				
		def accepted
			where(accepted: true)
		end
	end

	# default_scope ->{ where(:country_of_origin.ne => "United States") }
	scope :international, ->{ where(:country_of_origin.ne => "United States") }
	scope :awaiting_approval, -> {
		where(	:subscriber_account_number.nin => ["", nil],
				active: false )}
	scope :awaiting_subscription_activation, -> {
		where(	:subscriber_account_number.nin => ["", nil],
				active: true,
				subscription_expiration: nil )}
	scope :with_expired_subscription, -> {
		where(	:subscriber_account_number.nin => ["", nil],
				active: true,
				:subscription_expiration.lt => Date.today )}

################
# MODEL METHODS
################

	def has_inventory?
		return true if InventoryAdjustment.any_in(:product_id => self.products.pluck(:id)).present?
	end

	def display_subscriber_account_number
		if self.subscriber_account_number.blank? 
			return "n/a"
		else
			return "LB-#{self.subscriber_account_number}"
		end
	end

	def all_product_photos
		# First, finding ids of products
		ids = Product.where(brand_id: self.id).only(:_id).map(&:id)
		# Then, find photos of those products
		photos = ProductPhoto.any_in(:photographable_id => ids)

		return photos

	end

	def completeness_percentage

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
			:key_retailers,
			:trends,
			:brand_photos,
			:products,
			:press_hits,
			:patents,
			:trademarks,
			:compliances,
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
		
		total_items = items_present.count + 2 # add 1 for SOCIAL MEDIA test and 1 for CHANNEL CAPACITIES test

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
			user.contact.phone.blank? ||
			self.products.blank?
				return 1
		else
			return 2
		end

	end

	def set_subscriber_account_number
		unless self.subscriber_account_number.present?
			next_number = Brand.max(:subscriber_account_number)
			if next_number == nil
				self.subscriber_account_number = 100001 #set first if not present
			else
				begin
					next_number += 1
					self.subscriber_account_number = next_number
				end while Brand.where(subscriber_account_number: next_number).exists?
			end
		end
	end
end
