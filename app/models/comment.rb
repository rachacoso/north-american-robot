class Comment
  include Mongoid::Document
	include Mongoid::Timestamps::Short
  
  embedded_in :commentable, polymorphic: true
  
  field :author, type: String # for orders -> as 'brand' or 'orderer'
  field :text, type: String
  field :order_status, type: String # for orders, which stage (order status) was this comment created?

  validates :text, presence: true
  validates :author, presence: true

	scope :open, ->{where(order_status: "open")}
  scope :submitted_comment_from_brand, ->{where(order_status: "submitted", author: "brand")}
  scope :submitted_comment_from_orderer, ->{where(order_status: "submitted", :author.in => ["retailer", "distributor"])}

end