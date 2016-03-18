class Brand
  include Mongoid::Document
  include Mongoid::Timestamps::Short
	include Mongoid::Paperclip

	field :subscriber, type: Mongoid::Boolean
	field :active, type: Mongoid::Boolean, default: true
	
	# LOGINS/USERS WHO CAN ACT ON BEHALF OF BRAND
	has_many :users

  #####################
	### Profile
	#####################
 	# General Info
 	field :company_name, type: String
	field :country_of_origin, type: String
	field :year_established, type: Date
	field :company_size, type: String
	field :website, type: String
	field :facebook, type: String
	field :linkedin, type: String
	field :twitter, type: String
	field :instagram, type: String
	field :brand_positioning, type: String # now referenced as "company introduction" in ui

	field :completeness, type: Integer, default: 0 # 0-3 depending on completeness of profile fields
	field :last_login, type: DateTime
	embeds_one :address, as: :addressable
	has_many :contacts, as: :contactable, dependent: :destroy
	has_many :tags, as: :taggable, dependent: :destroy

	accepts_nested_attributes_for :contacts, :address

	has_mongoid_attached_file :logo, 
  	# :path => ':attachment/:id/:style.:extension',
	  # :url => ":s3_domain_url",
	  :default_url => "https://s3.amazonaws.com/landingintl-us/defaults/Default_Logo.png",
	  :styles => {
	    :medium    => ['200x90'],
	    # :public    => ['200x200']
	    :profile_tile => ['x90>']
	  },
	  # :convert_options => {:public => "-blur 0x20"},
	  :default_style => :medium
	validates_attachment_content_type :logo, :content_type=>['image/jpeg', 'image/png', 'image/gif']

	# SOCIAL IMPACT

	field :social_causes, type: String
	field :social_organizations, type: String
	field :social_give_back, type: String


  has_and_belongs_to_many :sectors, inverse_of: nil
  has_and_belongs_to_many :subsectors, inverse_of: nil 
	has_and_belongs_to_many :channels, inverse_of: nil 
  
	has_and_belongs_to_many :key_retailers, inverse_of: nil
	has_and_belongs_to_many :trends, inverse_of: nil

  has_many :brand_photos, dependent: :destroy

  has_many :library_documents, as: :documentable, dependent: :destroy

	# Current/Future SKUs
	has_many :products, dependent: :destroy

	# Marketing Acivities
	has_many :press_hits, dependent: :destroy
	has_many :trade_shows, dependent: :destroy

	# Channel Capacity
	has_many :channel_capacities, dependent: :destroy

	has_many :patents, dependent: :destroy
	has_many :trademarks, dependent: :destroy
	has_many :compliances, dependent: :destroy

	# Countries Where Exported
	# field :countries_where_exported, type: String
	embeds_many :export_countries, as: :exportable, cascade_callbacks: true


	# V2 ORDERING
	has_many :orders

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

	scope :subscribed, ->{where(subscriber: true)}
	scope :activated, ->{where(active: true)}


################
# MODEL METHODS
################

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

end
