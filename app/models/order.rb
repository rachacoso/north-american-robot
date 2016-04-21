class Order # for V2 ordering
  include Mongoid::Document
	include Mongoid::Timestamps::Short
  include LandingArmorPayments::Order

  # Ordering FROM
  belongs_to :brand
  # Ordered BY
  belongs_to :orderer, polymorphic: true
  # log who sent it
  belongs_to :user

  embeds_many :order_items, cascade_callbacks: true
  embeds_many :order_additional_charges, cascade_callbacks: true
  accepts_nested_attributes_for :order_items, :order_additional_charges

  field :status, type: String, default: "open" # Values: OPEN, SUBMITTED, PENDING, COMPLETE
  field :orderer_company_name, type: String
  field :brand_company_name, type: String
  field :submission_date, type: DateTime
  field :pending_date, type: DateTime
  field :completion_date, type: DateTime

  field :discount, type: Integer, default: 50 # discount in % - defaults to 50% discount
  validates :discount, numericality: { less_than_or_equal_to: 100, greater_than_or_equal_to: 0 }

  scope :current, ->{where(status: "open")}
  scope :submitted, ->{where(status: "submitted")}
  scope :pending, ->{where(status: "pending")}
  scope :shipped, ->{where(status: "shipped")}
  scope :complete, ->{where(status: "complete")}
  scope :active, ->{any_of(:status.in => ["open","submitted","pending"])}

  def subtotal_price # price before addtional fees in dollars
    price = 0
    self.order_items.each do |item|
      price += item.quantity * item.tiered_price
    end
    return price / 100
  end

  def charges_subtotal_price # price before addtional fees in dollars
    amount = 0
    self.order_additional_charges.each do |item|
      amount += item.amount
    end
    return amount.to_f / 100
  end

  def total_price
    return self.charges_subtotal_price + self.subtotal_price
  end

  def submission
    self.status = "submitted"
    self.submission_date = DateTime.now
    self.save!
    OrderMailer.send_submitted_order(self).deliver
  end

  def pending
    self.api_create_order
    unless self.errors.any?
      self.status = "pending"
      self.pending_date = DateTime.now
      self.save!
      OrderMailer.send_pending_order(self).deliver
    end
  end

  def viewable_by?(user)
    return true if self.orderer == user.company || self.brand == user.company
  end

end
