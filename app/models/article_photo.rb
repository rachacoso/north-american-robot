class ArticlePhoto
  include Mongoid::Document
	include Mongoid::Paperclip

	field :position, type: Integer
  has_mongoid_attached_file :photo, 
  	# :path => ':attachment/:id/:style.:extension',
	  # :url => ":s3_domain_url",
	  :styles => {
			:small    => ['100x100'],
	    :preview  => ['268x178'],
	    :medium		=> ['400x400'],
	    :large    => ['800>'],
	    :carousel	=> ['828x300^']
	  },
		:convert_options => { 
			:small => "-alpha remove -background white", 
			:medium => "-alpha remove -background white", 
			:large => "-alpha remove -background white",
			:carousel => "-alpha remove -background white -gravity center -crop '828x300+0+0' ",
		}

	validates_attachment_content_type :photo, :content_type=>['image/jpeg', 'image/png', 'image/gif']
	
	belongs_to :article
end