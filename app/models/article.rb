class Article
  include Mongoid::Document
  include Mongoid::Paperclip
  
  field :headline, type: String, default: ""
  field :preview_text, type: String, default: ""
  field :body, type: String, default: ""
	field :author, type: String, default: ""
  field :date, type: Date, default: -> { DateTime.now }
  field :active, type: Mongoid::Boolean, default: false
  field :article_type, type: Integer # 1 = on brands ; 2 = on trends ; 3 = product spotlight ; 4 = instructional; 5 = product link

  # list of associated brands
  has_and_belongs_to_many :brands, inverse_of: nil

  # list of associated products
  has_and_belongs_to_many :products, inverse_of: nil

	#photos
	has_many :article_photos, dependent: :destroy

  has_mongoid_attached_file :carousel_photo, 
    :styles => {
      :full    => ['1440'],
    },
    :default_style => :full
  validates_attachment_content_type :carousel_photo, :content_type=>['image/jpeg', 'image/png', 'image/gif']

  has_mongoid_attached_file :tile_photo, 
    :styles => {
      :tile    => ['350x350^'],
    },
    :default_style => :tile,
    :convert_options => { 
      :tile => "-alpha remove -background white -gravity center -extent 350x350 ",
    }
  validates_attachment_content_type :tile_photo, :content_type=>['image/jpeg', 'image/png', 'image/gif']

	validates :headline, presence: true

	scope :on_brands, ->{where(article_type: 1)}
	scope :on_trends, ->{where(article_type: 2)}
  scope :brand_and_trends, -> {where(:article_type.in => [1,2])}
  scope :spotlight, ->{where(article_type: 3)}
  scope :instructional, ->{where(article_type: 4)}
  scope :product_link, ->{where(article_type: 5)}
  scope :tiles_articles, ->{where(:article_type.in => [1,2,3,4])}
	scope :active, ->{where(active: true)}
	scope :inactive, ->{where(active: false)}
  scope :carousel, ->{where(:carousel_photo_file_name.nin => ["", nil])}
  scope :no_carousel, ->{where(:carousel_photo_file_name.in => ["", nil])}

end