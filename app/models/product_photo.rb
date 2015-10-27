class ProductPhoto
  include Mongoid::Document
	include Mongoid::Paperclip

	field :position, type: Integer
  has_mongoid_attached_file :photo, 
  	# :path => ':attachment/:id/:style.:extension',
	  # :url => ":s3_domain_url",
	  :styles => {
	    :small    => ['100x100'],
	    :medium		=> ['400x400'],
	    :large    => ['800>'],
	    :profile_tile    => ['275x180', :jpg]
	  },
		:convert_options => { 
			:profile_tile => "-alpha remove -background white -gravity center -extent 275x180", 
			:small => "-alpha remove -background white", 
			:medium => "-alpha remove -background white", 
			:large => "-alpha remove -background white" 
		}

	validates_attachment_content_type :photo, :content_type=>['image/jpeg', 'image/png', 'image/gif']
	
	belongs_to :photographable, polymorphic: true  
end
