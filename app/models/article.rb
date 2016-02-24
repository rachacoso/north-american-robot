class Article
  include Mongoid::Document

  field :headline, type: String, default: ""
  field :body, type: String, default: ""
	field :author, type: String, default: ""
  field :date, type: Date, default: -> { DateTime.now }
  field :active, type: Mongoid::Boolean, default: false
  field :article_type, type: Integer

  # list of associated brands
  has_and_belongs_to_many :brands, inverse_of: nil
  
	#photos
	has_many :article_photos, dependent: :destroy

	validates :headline, presence: true

	scope :on_brands, ->{where(article_type: 1)}
	scope :on_trends, ->{where(article_type: 2)}
	scope :active, ->{where(active: true)}
	scope :inactive, ->{where(active: false)}

end