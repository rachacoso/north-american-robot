class Retailer
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
 	# Company Information

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

 	field :company_name, type: String
	field :country_of_origin, type: String
	field :year_established, type: Date
	field :website, type: String
	field :company_size, type: String
	field :facebook, type: String
	field :linkedin, type: String
	field :twitter, type: String
	field :instagram, type: String
	embeds_one :address, as: :addressable

	# COMPANY CONTACTS
	has_many :contacts, as: :contactable, dependent: :destroy
	accepts_nested_attributes_for :contacts, :address

	# RETAILER STORY
	field :company_introduction, type: String
	has_many :tags, as: :taggable, dependent: :destroy
  has_and_belongs_to_many :sectors, inverse_of: nil
  has_and_belongs_to_many :subsectors, inverse_of: nil 
	field :number_of_locations, type: Integer
	field :number_of_brands_sold, type: Integer
	# Countries of Operation
	embeds_many :export_countries, as: :exportable, store_as: "countries_of_operation", cascade_callbacks: true



	# MARKETING/PR CAPABILITIES
	field :internal_marketing_size, type: Integer
	field :has_external_marketing, type: Boolean
	field :where_product_advertised, type: String
	field :customer_database_size, type: Integer
	has_many :trade_shows, dependent: :destroy


	# GIVING PLACE

	field :social_causes, type: String # Social Ethos & Impact
	field :social_organizations, type: String # Organizations you support
	field :social_give_back, type: String # How you give back


	# OTHER

	field :completeness, type: Integer, default: 0 # 0-3 depending on completeness of profile fields
	field :last_login, type: DateTime
	


	# VERIFICATION
	# CONTROLLED/ADDED BY RETAILER
	field :business_id, type: String # BUSINESS REGISTRATION
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

	# def all_product_photos
	# 	# First, finding ids of products
	# 	ids = Product.where(brand_id: self.id).only(:_id).map(&:id)
	# 	# Then, find photos of those products
	# 	photos = ProductPhoto.any_in(:photographable_id => ids)

	# 	return photos

	# end

	# def completeness_percentage

	# 	# items to test for present-ness (i.e. field exists AND has content)
	# 	items_present = [
	# 		:company_name,
	# 		:country_of_origin,
	# 		:year_established,
	# 		:company_size,
	# 		:website,
	# 		:logo_file_name,			
	# 		:export_countries,
	# 		:sectors,
	# 		:channels,
	# 		:key_retailers,
	# 		:trends,
	# 		:brand_photos,
	# 		:products,
	# 		:press_hits,
	# 		:patents,
	# 		:trademarks,
	# 		:compliances,
	# 		:trade_shows
	# 	]

	# 	items_passed = 0

	# 	puts "xxxxxxx"

	# 	# check social media (only need one)
	# 	if self.facebook.present? || self.linkedin.present?
	# 		items_passed += 1
	# 	end

	# 	# check channel capacities (all must be complete)
	# 	cc_incomplete = self.channel_capacities.where(capacity: nil).count
	# 	puts "incomplete channel capacities: #{cc_incomplete}"
	# 	unless cc_incomplete > 0
	# 		items_passed += 1
	# 	end

	# 	# PRESENT test
	# 	items_present.each do |item|
	# 		if self.send(item).present?
	# 			items_passed += 1
	# 			puts "#{item} YES"
	# 		else
	# 			puts "#{item} NO"
	# 		end
	# 	end
	# 	puts "yyyyyyyy"
		
	# 	total_items = items_present.count + 2 # add 1 for SOCIAL MEDIA test and 1 for CHANNEL CAPACITIES test

	# 	total_percent = (items_passed.to_f / total_items) * 100
	# 	puts total_percent

	# 	return total_percent.round
		
	# end

	# def update_completeness

	# 	percent = self.completeness_percentage
	# 	case percent
	# 	when 50..75
	# 		completeness_level = 1
	# 	when 75..99
	# 		completeness_level = 2
	# 	when 100..(1.0/0.0)
	# 		completeness_level = 3
	# 	else
	# 		completeness_level = 0
	# 	end
	# 	self.completeness = completeness_level
	# 	self.save

	# end

end
