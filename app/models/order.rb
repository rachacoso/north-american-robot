class Order # for V2 ordering
  include Mongoid::Document
	include Mongoid::Timestamps::Short
  
  # Ordering FROM
  belongs_to :brand
  # Ordered BY
  belongs_to :orderer, polymorphic: true
  # belongs_to :distributor
  # belongs_to :retailer
  # log who sent it
  belongs_to :user

  embeds_many :order_items, cascade_callbacks: true
  field :status, type: String, default: "open" # Values: OPEN, PENDING, CLOSED

  scope :open, ->{where(status: "open")}
  scope :submitted, ->{where(status: "submitted")}
  scope :pending, ->{where(status: "pending")}
  scope :closed, ->{where(status: "closed")}

  def total_price # in dollars
    price = 0
    self.order_items.each do |item|
      price += item.quantity * item.product.tiered_price
    end
    return price / 100
  end

end
