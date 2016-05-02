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
  field :ship_to_name, type: String
  embeds_one :shipping_address, class_name: "Address", inverse_of: :addressable
  accepts_nested_attributes_for :order_items, :order_additional_charges, :shipping_address


  field :status, type: String, default: "open" # Values: OPEN, SUBMITTED, PENDING, APPROVED, PAID, SHIPPED, DELIVERED, COMPLETED, ERROR
  field :status_error_message, type: String
  field :orderer_company_name, type: String
  field :brand_company_name, type: String
  field :submission_date, type: DateTime
  field :pending_date, type: DateTime
  field :approved_date, type: DateTime
  field :paid_date, type: DateTime
  field :shipped_date, type: DateTime
  field :delivered_date, type: DateTime
  field :completed_date, type: DateTime
  field :error_date, type: DateTime

  field :discount, type: Integer, default: 50 # discount in % - defaults to 50% discount
  validates :discount, numericality: { less_than_or_equal_to: 100, greater_than_or_equal_to: 0 }

  scope :current, ->{where(status: "open")}
  scope :submitted, ->{where(status: "submitted")}
  scope :pending, ->{where(status: "pending")}
  scope :approved, ->{where(status: "approved")}
  scope :paid, ->{where(status: "paid")}
  scope :shipped, ->{where(status: "shipped")}
  scope :delivered, ->{where(status: "delivered")}
  scope :completed, ->{where(status: "completed")}
  scope :error, ->{where(status: "error")}
  scope :active, ->{any_of(:status.in => ["open","submitted","pending","approved","paid", "shipped","delivered"])}

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
    OrderMailer.send_order(
      order: self, 
      status: "submitted", 
      email: "order@landingintl.com", # send to brand/landing (currently just sending to Landing)
      subject: "Landing International: Order Submitted"
      ).deliver
  end

  def pending
    self.status = "pending"
    self.pending_date = DateTime.now
    self.save!
    OrderMailer.send_order(
      order: self, 
      status: "pending", 
      email: self.user.email, # send to orderer email (using the order creator's email in this case)
      subject: "Landing International: Order Updated"
      ).deliver
  end

  def approval
    self.api_create_order
    unless self.errors.any?
      self.status = "approved"
      self.approved_date = DateTime.now
      self.save!
      OrderMailer.send_order(
        order: self, 
        status: "approved", 
        email: "order@landingintl.com", # send to brand/landing (currently just sending to Landing)
        subject: "Landing International: Order Approved"
        ).deliver
    end
  end

  def paid
    self.status = "paid"
    self.paid_date = DateTime.now
    self.save!
    OrderMailer.send_order(
      order: self,
      status: "paid",
      email: "order@landingintl.com", # send to brand/landing (currently just sending to Landing)
      subject: "Landing International: Order Paid to Escrow"
      ).deliver
  end

  def shipped
    self.status = "shipped"
    self.shipped_date = DateTime.now
    self.save!
    OrderMailer.send_order(
      order: self,
      status: "shipped",
      email: self.user.email, # send to orderer email (using the order creator's email in this case)
      subject: "Landing International: Order Shipped"
      ).deliver
  end

  def delivered
    self.status = "delivered"
    self.delivered_date = DateTime.now
    self.save!
    OrderMailer.send_order(
      order: self,
      status: "delivered",
      email: self.user.email, # send to orderer email (using the order creator's email in this case)
      subject: "Landing International: Order Delivered"
      ).deliver
    OrderMailer.send_order(
      order: self,
      status: "delivered",
      email: "order@landingintl.com", # send to brand/landing (currently just sending to Landing)
      subject: "Landing International: Order Delivered"
      ).deliver
  end

  def completed
    self.status = "completed"
    self.completed_date = DateTime.now
    self.save!
    OrderMailer.send_order(
      order: self,
      status: "completed",
      email: self.user.email, # send to orderer email (using the order creator's email in this case)
      subject: "Landing International: Order Completed"
      ).deliver
    OrderMailer.send_order(
      order: self,
      status: "completed",
      email: "order@landingintl.com", # send to brand/landing (currently just sending to Landing)
      subject: "Landing International: Order Completed"
      ).deliver
  end

  def error(status:, message:)
    self.status = "error"
    self.status_error_message = "Status #{status}: #{message}"
    self.error_date = DateTime.now
    self.save!
    OrderMailer.send_order(
      order: self,
      status: "error",
      email: self.user.email, # send to orderer email (using the order creator's email in this case)
      subject: "Landing International: Order Completed"
      ).deliver
    OrderMailer.send_order(
      order: self,
      status: "error",
      email: "order@landingintl.com", # send to brand/landing (currently just sending to Landing)
      subject: "Landing International: Order Errors"
      ).deliver
  end

  def viewable_by?(user)
    return true if self.orderer == user.company || self.brand == user.company
  end

end
