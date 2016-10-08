module CompanyCommons

	module BuyersAndSellers
		extend ActiveSupport::Concern

		included do
			field :subscriber, type: Mongoid::Boolean
			field :active, type: Mongoid::Boolean, default: true
			
			# LOGINS/USERS WHO CAN ACT ON BEHALF OF BRAND
			has_many :users, dependent: :destroy

			# v2 brand/retailer/distributor relation
			has_many :users, as: :company, dependent: :destroy

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


			# Company Information
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
			accepts_nested_attributes_for :address
			has_many :contacts, as: :contactable, dependent: :destroy
			accepts_nested_attributes_for :contacts

			has_and_belongs_to_many :sectors, inverse_of: nil 
			has_and_belongs_to_many :subsectors, inverse_of: nil 
			has_many :tags, as: :taggable, dependent: :destroy

			# MARKETING ACTIVITIES
			has_many :trade_shows, dependent: :destroy


			# GIVING PLACE
			field :social_causes, type: String
			field :social_organizations, type: String
			field :social_give_back, type: String

			# OTHER
			field :completeness, type: Integer, default: 0 # 0-3 depending on completeness of profile fields
			field :last_login, type: DateTime

			scope :subscribed, ->{where(subscriber: true)}
			scope :activated, ->{where(active: true)}

		end

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

	end

	module BuyersOnly
		extend ActiveSupport::Concern

	  included do

	  	# RETAILER/DISTRIBUTOR STORY
	  	field :company_introduction, type: String

	  	# PAYMENTS & SHIPPING
	    field :payment_terms, type: String, default: "Prepayment" # Prepayment, Net 30, Net 45, Net 60
	    field :receives_direct_shipments, type: Boolean
	    field :multiple_distribution_centers, type: Boolean
	    field :pays_for_international_shipping, type: Boolean
	    field :pays_for_domestic_shipping, type: Boolean
	    
	    # REQUIREMENTS
	    field :ticketing, type: Boolean
	    field :testers, type: Boolean
	    field :gratis, type: Boolean
	    field :co_op, type: Boolean
	    field :damages_budget, type: Boolean
	    field :comissions, type: Boolean
	    field :sales_training, type: Boolean
	    field :education_materials, type: Boolean

			# MARKETING/PR CAPABILITIES
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

			# V2 ORDERING
			has_many :orders, as: :orderer

			# VERIFICATION
			# CONTROLLED/ADDED BY BUYER
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

	  end
	end

end