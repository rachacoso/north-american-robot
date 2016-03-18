class Order # for V2 ordering
  include Mongoid::Document
	include Mongoid::Timestamps::Created::Short
  
  # Ordering FROM
  belongs_to :brand
  # Ordered BY
  belongs_to :distributor
  belongs_to :retailer
  # log who sent it
  belongs_to :user

  has_many :order_items
  field :status, type: String, default: "open" # Values: OPEN, CLOSED

  scope :open, ->{where(status: "open")}
  scope :closed, ->{where(status: "closed")}

end
