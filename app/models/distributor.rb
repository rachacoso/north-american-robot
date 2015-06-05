class Distributor
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
	field :rating, type: Integer, default: 0 # validation rating 0-7 based on validation criterion
	field :completeness, type: Integer, default: 0 # 0-3 depending on completeness of profile fields
	embeds_one :address, as: :addressable
 	has_many :contacts, as: :contactable, dependent: :destroy
 	has_many :tags, as: :taggable, dependent: :destroy
 	
	accepts_nested_attributes_for :address

	has_mongoid_attached_file :logo, 
  	# :path => ':attachment/:id/:style.:extension',
	  # :url => ":s3_domain_url",
	  :default_url => "https://s3.amazonaws.com/landingintl-us/defaults/Default_Logo.png",
	  :styles => {
	    :medium    => ['200x90'],
	    :profile_tile => ['x90>']
	    # :public    => ['200x200']
	  },
	  # :convert_options => {:public => "-blur 0x20"},
	  :default_style => :medium
	validates_attachment_content_type :logo, :content_type=>['image/jpeg', 'image/png', 'image/gif']


	# Countries of Distribution
	embeds_many :export_countries, as: :exportable

  has_and_belongs_to_many :sectors, inverse_of: nil 
	has_and_belongs_to_many :channels, inverse_of: nil 
  

	# Current/Past Portfolio
	has_many :distributor_brands, dependent: :destroy

	# Channel Capacity
	
	has_many :channel_capacities, dependent: :destroy


	# Sales/Education Capabilities
	field :outside_sales_size, type: Integer
	field :inside_sales_size, type: Integer


	# Marketing/PR Capabilities
	field :internal_marketing_size, type: Integer
	field :employ_pr_agency, type: Boolean
	field :marketing_via_print, type: Boolean
	field :marketing_via_online, type: Boolean
	field :marketing_via_email, type: Boolean
	field :marketing_via_outdoor, type: Boolean
	field :marketing_via_events, type: Boolean
	field :marketing_via_direct_mail, type: Boolean
	field :marketing_via_classes, type: Boolean
	field :customer_database_size, type: Integer

	has_many :trade_shows, dependent: :destroy

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


	# VERIFICATION
	# CONTROLLED BY ADMIN
	field :verified_website, type: Boolean
	field :verified_social_media, type: Boolean # facebook or linkedin
	field :verified_client_brand, type: Boolean # verfication of current brand client
	field :verified_business_registration, type: Boolean # verfication of government registration
	field :verified_business_certificate, type: Boolean # verfication of uploaded certificate doc
	field :verified_location, type: Boolean
	field :verified_brand_display, type: Boolean
	field :verification_notes, type: String 	# place to put addtional notes on the verification (visible to landing only)

	# CONTROLLED BY USER
  has_mongoid_attached_file :verification_location_photo, 
  	# :path => ':attachment/:id/:style.:extension',
	  # :url => ":s3_domain_url",
	  :default_url => "https://s3.amazonaws.com/landingintl-us/defaults/Default_Logo.png",
	  :styles => {
	    :small    => ['100x100#'],
	    :medium		=> ['400'],
	    :large    => ['800>']
	  }
	validates_attachment_content_type :verification_location_photo, :content_type=>['image/jpeg', 'image/png', 'image/gif']
  
  has_mongoid_attached_file :verification_brand_display_photo, 
  	# :path => ':attachment/:id/:style.:extension',
	  # :url => ":s3_domain_url",
	  :default_url => "https://s3.amazonaws.com/landingintl-us/defaults/Default_Logo.png",
	  :styles => {
	    :small    => ['100x100#'],
	    :medium		=> ['400'],
	    :large    => ['800>']
	  }
	validates_attachment_content_type :verification_brand_display_photo, :content_type=>['image/jpeg', 'image/png', 'image/gif']

  has_mongoid_attached_file :verification_business_certificate
  	# :path => ':attachment/:id/:style.:extension',
	  # :url => ":s3_domain_url",
	validates_attachment_content_type :verification_business_certificate, 
		:content_type=>[	'application/pdf', 
											'application/vnd.ms-powerpoint', 
											'application/msword',
											'application/vnd.openxmlformats-officedocument.presentationml.slideshow',
											'application/vnd.openxmlformats-officedocument.presentationml.presentation',
											'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
											'image/jpeg', 
											'image/png', 
											'image/gif'
										]
	validates_attachment_size :verification_business_certificate, :in => 0.megabytes..2.megabytes

	scope :subscribed, ->{where(subscriber: true)}
	scope :activated, ->{where(active: true)}

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

		return total_percent
		
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
