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

  has_and_belongs_to_many :sectors, inverse_of: nil 
	has_and_belongs_to_many :channels, inverse_of: nil 
  
  has_many :brand_photos, dependent: :destroy

  has_many :library_documents, as: :documentable, dependent: :destroy

	# Current/Future SKUs
	has_many :products, dependent: :destroy

	# Marketing Acivities
	field :brand_positioning, type: String
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

end
