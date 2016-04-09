class Order # for V2 ordering
  include Mongoid::Document
	include Mongoid::Timestamps::Short
  
  # Ordering FROM
  belongs_to :brand
  # Ordered BY
  belongs_to :orderer, polymorphic: true
  # log who sent it
  belongs_to :user

  embeds_many :order_items, cascade_callbacks: true
  field :status, type: String, default: "open" # Values: OPEN, SUBMITTED, PENDING, COMPLETE
  field :orderer_company_name, type: String
  field :brand_company_name, type: String
  field :submission_date, type: DateTime
  field :completion_date, type: DateTime

  field :discount, type: Integer, default: 50 # discount in % - defaults to 50% discount
  validates :discount, numericality: { less_than_or_equal_to: 100, greater_than_or_equal_to: 0 }

  scope :current, ->{where(status: "open")}
  scope :submitted, ->{where(status: "submitted")}
  scope :pending, ->{where(status: "pending")}
  scope :complete, ->{where(status: "complete")}
  scope :active, ->{any_of(:status.in => ["open","submitted","pending"])}

  def total_price # in dollars
    price = 0
    self.order_items.each do |item|
      price += item.quantity * item.tiered_price
    end
    return price / 100
  end

  def setup(orderer, user, brand)
    self.orderer = orderer
    self.orderer_company_name = orderer.company_name
    self.user = user
    self.brand = brand
    self.brand_company_name = brand.company_name
    self.save!
  end

  def submission
    self.status = "submitted"
    self.submission_date = DateTime.now
    self.save!
    OrderMailer.send_order(self).deliver
  end

end
