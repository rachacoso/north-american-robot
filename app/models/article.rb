class Article
  include Mongoid::Document
  include Mongoid::Paperclip
  
  field :headline, type: String, default: ""
  field :preview_text, type: String, default: ""
  field :body, type: String, default: ""
	field :author, type: String, default: ""
  field :date, type: Date, default: -> { DateTime.now }
  field :active, type: Mongoid::Boolean, default: false
  field :article_type, type: Integer

  # list of associated brands
  has_and_belongs_to_many :brands, inverse_of: nil
  
	#photos
	has_many :article_photos, dependent: :destroy

  has_mongoid_attached_file :carousel_photo, 
    :styles => {
      :full    => ['1440'],
    },
    :default_style => :full
  validates_attachment_content_type :carousel_photo, :content_type=>['image/jpeg', 'image/png', 'image/gif']

	validates :headline, presence: true

	scope :on_brands, ->{where(article_type: 1)}
	scope :on_trends, ->{where(article_type: 2)}
	scope :active, ->{where(active: true)}
	scope :inactive, ->{where(active: false)}
  scope :carousel, ->{where(:carousel_photo_file_name.nin => ["", nil])}

end