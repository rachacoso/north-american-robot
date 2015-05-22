class Display
  include Mongoid::Document
	include Mongoid::Paperclip

  has_mongoid_attached_file :background_photo,
		# :path => ':attachment/:id/:style.:extension',
		# :url => ":s3_domain_url",  
		:styles => {
			:small    => ['100x100#',   :jpg],
			:large    => ['1280',   :jpg]
		}
	validates_attachment_content_type :background_photo, :content_type=>['image/jpeg', 'image/png', 'image/gif', 'image/svg+xml']

	field :background_color, type: String


  has_mongoid_attached_file :default_product_photo,
		# :path => ':attachment/:id/:style.:extension',
		# :url => ":s3_domain_url",  
	  :styles => {
	    :small    => ['100x100#'],
	    :medium		=> ['400'],
	    :large    => ['800>']
	  }
	 	validates_attachment_content_type :default_product_photo, :content_type=>['image/jpeg', 'image/png', 'image/gif', 'image/svg+xml']

	# field :section, type: String #which section is this for (future?)

end

