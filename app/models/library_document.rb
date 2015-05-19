class LibraryDocument
  include Mongoid::Document
	include Mongoid::Paperclip

	field :type, type: String
  has_mongoid_attached_file :file
  	# :path => ':attachment/:id/:style.:extension',
	  # :url => ":s3_domain_url",
	validates_attachment_content_type :file, 
		:content_type=>[	'application/pdf', 
											'application/vnd.ms-excel', 
											'application/vnd.ms-powerpoint', 
											'application/msword',
											'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
											'application/vnd.openxmlformats-officedocument.presentationml.slideshow',
											'application/vnd.openxmlformats-officedocument.presentationml.presentation',
											'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
										]

	validates_attachment_size :file, :in => 0.megabytes..2.megabytes

	belongs_to :documentable, polymorphic: true  
end
