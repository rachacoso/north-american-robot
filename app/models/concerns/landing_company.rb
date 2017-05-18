module LandingCompany

	module Sellers
		extend ActiveSupport::Concern

		included do
			# V2 ORDERING
			has_many :orders
			field :order_minimum, type: Integer # minimum order as dollar amount / stored as cents
			field :landing_commission, type: Integer, default: 10 #landing commission percentage
			field :landing_fulfillment_services, type: Boolean
			validates :landing_commission, numericality: { less_than_or_equal_to: 20, greater_than_or_equal_to: 1 }
			# Payment Information
			field :bank_name, type: String
			field :bank_swift_code, type: String
			field :bank_city, type: String
			field :bank_country, type: String
			field :bank_account_number, type: String
			field :beneficiary_business_name, type: String
			field :beneficiary_name, type: String
			field :beneficiary_address, type: String
		end

	end



	module BuyersAndSellers
		extend ActiveSupport::Concern

		included do
			# field :subscriber, type: Mongoid::Boolean
			field :subscription_expiration, type: Date
			field :date, type: Date
			field :active, type: Mongoid::Boolean, default: proc { self.class.to_s == "Brand" ?  false : true }

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
			scope :activated, ->{where(active: true, :company_name.nin => ["",nil], :country_of_origin.nin => ["",nil])}

		end

		def set_sectors(sec)
			assigned_sectors = Sector.find(sec.values) rescue []
			# unless assigned_sectors.blank?
				self.sectors = [] # clear current ones before update
			# end
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
			return subsector_parents.uniq
		end

		def subscriber?
			if self.subscription_expiration && self.subscription_expiration > Date.today
				return true
			else
				return false
			end
		end

		def set_subscription_expiration
			self.subscription_expiration = Date.today + 1.year
			self.save
		end

		def reset_subscription_expiration
			self.subscription_expiration = nil
			self.save
		end

	end

	module Buyers
		extend ActiveSupport::Concern

	  included do

	  	# RETAILER/DISTRIBUTOR STORY
	  	field :company_introduction, type: String



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

	module OrderTermsAndRequirements
		extend ActiveSupport::Concern

		included do
			# PAYMENTS & SHIPPING
			field :payment_terms, type: String, default: "Prepay" # Prepay, Net 30, Net 45, Net 60
			field :us_shipping_terms, type: String # "Brand", "Retailer", or "Other - [Manual Input...]"
			field :accepts_overseas_shipment, type: Boolean
			field :other_terms, type: String
			# field :multiple_distribution_centers, type: Boolean
			# field :pays_for_international_shipping, type: Boolean
			# field :pays_for_domestic_shipping, type: Boolean

			# REQUIREMENTS
			field :margin, type: Integer, default: 50 # discount in % - defaults to 50% discount
			validates :margin, numericality: { less_than_or_equal_to: 100, greater_than_or_equal_to: 0 }
			field :marketing_co_op, type: Integer, default: 0
			validates :marketing_co_op, numericality: { less_than_or_equal_to: 100, greater_than_or_equal_to: 0 }
			field :damages_budget, type: Integer, default: 0
			validates :damages_budget, numericality: { less_than_or_equal_to: 100, greater_than_or_equal_to: 0 }
			field :product_ticketing, type: Boolean
			field :retailer_edi, type: Boolean
			field :routing_guide, type: Boolean
			# field :testers, type: Boolean
			# field :gratis, type: Boolean
			# field :comissions, type: Boolean
			# field :sales_training, type: Boolean
			# field :education_materials, type: Boolean
		end

		def is_prepay?
			return true if self.payment_terms == "Prepay"
		end

		module Orders
			extend ActiveSupport::Concern

			included do #Brand specific attributes needed on order
				field :landing_commission, type: Integer, default: 10 #landing commission percentage
				field :landing_fulfillment_services, type: Boolean
				validates :landing_commission, numericality: { less_than_or_equal_to: 20, greater_than_or_equal_to: 1 }
			end

			def prepay_mark_as_paid # used for prepay orders
				if self.is_prepay?
					self.paid
				else 
					return false
				end
			end

			def add_terms_and_requirements
				self.payment_terms = self.orderer.payment_terms
				self.us_shipping_terms = self.orderer.us_shipping_terms
				self.accepts_overseas_shipment = self.orderer.accepts_overseas_shipment
				self.other_terms = self.orderer.other_terms

				self.margin = self.orderer.margin unless self.orderer.margin.blank? 
				self.discount = self.orderer.margin unless self.orderer.margin.blank? 
				self.marketing_co_op = self.orderer.marketing_co_op unless self.orderer.marketing_co_op.blank? 
				self.damages_budget = self.orderer.damages_budget unless self.orderer.damages_budget.blank?
				self.product_ticketing = self.orderer.product_ticketing
				self.retailer_edi = self.orderer.retailer_edi
				self.routing_guide = self.orderer.routing_guide
				if self.brand.landing_commission.present?
					self.landing_commission = self.brand.landing_commission
				else
					self.landing_commission = 10
				end
				self.landing_fulfillment_services = self.brand.landing_fulfillment_services
			end

		end

		module BuyerValidation
			extend ActiveSupport::Concern
			included do
				field :payment_terms_approved, type: Boolean
				field :margin_approved, type: Boolean

				scope :margin_pending, ->{ where( :margin.gt => 50 ).where( :margin_approved.ne => true ) }
				scope :payment_terms_pending, ->{ 
					any_of( 
						{:payment_terms => "Net 30"},
						{:payment_terms => "Net 45"},
						{:payment_terms => "Net 60"}
					).where( 
						:payment_terms_approved.ne => true 
					) 
				}
			end

			def set_payment_terms(terms)
				if terms == self.payment_terms # exit if no update needed
					return false
				else
					self.payment_terms = terms
					self.payment_terms_approved = false # reset approval if changed
					case terms
					when "Net 30", "Net 45", "Net 60"
						self.disable_armor_payments = true
					when "Prepay"
						self.disable_armor_payments = false
					end
					return true
				end
			end

			def set_margin(margin)
				if margin.to_i == self.margin # exit if no update needed
					return false
				else
					self.margin = margin
					self.margin_approved = false # reset approval if changed
					return true
				end
			end

			def payment_terms_valid?
				case self.payment_terms
				when "Net 30", "Net 45", "Net 60"
					if self.payment_terms_approved
						return true
					else
						return false
					end
				when "Prepay"
					return true
				end
			end

			def margin_valid?
				if self.margin > 50
					if self.margin_approved
						return true
					else
						return false
					end
				else # doesn't need validation if less than 50
					return true
				end
			end
		end


	end



end