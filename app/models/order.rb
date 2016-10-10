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
  embeds_many :comments, as: :commentable
  accepts_nested_attributes_for :order_items, :order_additional_charges, :shipping_address, :comments

  field :status, type: String, default: "open" # Values: OPEN, SUBMITTED, PENDING, APPROVED, PAID, SHIPPED, DELIVERED, COMPLETED, DISPUTED, ERROR
  field :status_error_message, type: String
  field :landing_order_reference_id, type: String
  field :orderer_company_name, type: String
  field :orderer_order_reference_id, type: String
  field :brand_company_name, type: String
  field :brand_order_reference_id, type: String
  field :submission_date, type: DateTime
  field :pending_date, type: Array
  field :approved_date, type: DateTime
  field :paid_date, type: DateTime
  field :shipped_date, type: DateTime
  field :delivered_date, type: DateTime
  field :disputed_date, type: DateTime
  field :completed_date, type: DateTime
  field :error_date, type: DateTime

  field :ship_date, type: DateTime
  field :ship_to_us_date, type: DateTime
  field :cancel_date, type: DateTime
  field :estimated_payment_date, type: DateTime

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
  scope :disputed, ->{where(status: "disputed")}
  scope :error, ->{where(status: "error")}
  scope :active, ->{any_of(:status.in => ["open","submitted","pending","approved","paid", "shipped","delivered","disputed"])}
  scope :active_brand, ->{any_of(:status.in => ["submitted","pending","approved","paid", "shipped","delivered","disputed"])}
  scope :in_progress, ->{any_of(:status.in => ["submitted","pending","approved","paid", "shipped","delivered","disputed"])}
  scope :editable, ->{any_of(:status.in => ["open","submitted","pending"])}

  def self.of_company(company_id:, type:)
    if type == "brand"
      where(brand_id: company_id)
    else #isn't a brand
      where(orderer_id: company_id)
    end
  end

  def can_be_deleted?
    if ["open","submitted","pending"].include? self.status
      return true
    else
      return false
    end
  end

  def subtotal_price # price before addtional fees in dollars
    price = 0
    self.order_items.each do |item|
      next if item.quantity.blank?
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

  def self.create_new(user:, brand:)
    order = Order.new
    order.orderer = user.company
    order.orderer_company_name = user.company.company_name
    order.ship_to_name = user.company.company_name
    order.user =  user
    order.brand = brand
    order.brand_company_name = brand.company_name
    unless user.company.disable_armor_payments
      order.armor_seller_account_id = brand.armor_account_id
      order.armor_seller_user_id = brand.users.with_armor_user_id.first.armor_user_id if brand.users.with_armor_user_id.present? 
      order.armor_seller_email = brand.users.with_armor_user_id.first.email if brand.users.with_armor_user_id.present?
      order.armor_buyer_account_id = order.orderer.armor_account_id
      order.armor_buyer_user_id = order.orderer.users.with_armor_user_id.first.armor_user_id if order.orderer.users.with_armor_user_id.present?
      order.armor_buyer_email = order.orderer.users.with_armor_user_id.first.email if order.orderer.users.with_armor_user_id.present?
    end
    order.build_shipping_address(
      address1: user.company.address.address1,
      address2: user.company.address.address2,
      city: user.company.address.city,
      state: user.company.address.state,
      postcode: user.company.address.postcode,
      country: user.company.address.country,
    )
    order.save!
    return order
  end

  def armor_update

    if self.orderer.disable_armor_payments # remove all armor ids if buyer turns off armor
      self.armor_buyer_account_id = nil if self.armor_buyer_account_id.present?
      self.armor_buyer_user_id = nil if self.armor_buyer_user_id.present?
      self.armor_buyer_email = nil if self.armor_buyer_email.present?
      self.armor_seller_account_id = nil if self.armor_seller_account_id.present?
      self.armor_seller_user_id = nil if self.armor_seller_user_id.present?
      self.armor_seller_email = nil if self.armor_seller_email.present?
    else
      self.armor_buyer_account_id ||= self.orderer.armor_account_id
      self.armor_buyer_user_id ||= self.orderer.users.with_armor_user_id.first.armor_user_id if self.orderer.users.with_armor_user_id.present?
      self.armor_buyer_email ||= self.orderer.users.with_armor_user_id.first.email if self.orderer.users.with_armor_user_id.present?
      self.armor_seller_account_id ||= self.brand.armor_account_id
      self.armor_seller_user_id ||= self.brand.users.with_armor_user_id.first.armor_user_id if self.brand.users.with_armor_user_id.present?
      self.armor_seller_email ||= self.brand.users.with_armor_user_id.first.email if self.brand.users.with_armor_user_id.present?
    end
    self.save!

  end

  def submission(user:)
    self.generate_id(:landing_order_reference_id)
    self.status = "submitted"
    self.submission_date = DateTime.now
    self.save!
    OrderMailer.send_order(
      order: self, 
      status: "submitted_brand", 
      email: self.brand.users.pluck(:email), # send to brand/landing (currently just sending to Landing)
      subject: "Good News! You have a new order request on Landing!",
      title: "Order Submitted"
      ).deliver
    OrderMailer.send_order(
      order: self, 
      status: "submitted_brand", 
      email: "orders@landingintl.com", # send to brand/landing (currently just sending to Landing)
      subject: "Good News! You have a new order request on Landing!",
      title: "Order Submitted"
      ).deliver
    OrderMailer.send_order(
      order: self, 
      status: "submitted_orderer", 
      email: self.orderer.users.pluck(:email), # send to buyer
      subject: "Congratulations! You submitted an order on Landing!",
      title: "Order Submitted"
      ).deliver
  end

  def pending(user:, comments: nil)
    self.status = "pending"
    self.push(pending_date: DateTime.now)
    self.comments.create(text: comments, author: user.type?, order_status: "pending")
    self.save!
    OrderMailer.send_order(
      order: self, 
      status: "pending", 
      email: self.orderer.users.pluck(:email), # send to orderer email
      subject: "Yippee! Your order has been approved.",
      title: "Order Pending Approval and Payment"
      ).deliver
  end

  def decline_approval(requests:, user:)
    self.status = "submitted"
    # self.pending_date = DateTime.now
    self.comments.create(text: requests, author: user.type?, order_status: "submitted")
    self.save!
    # NEED TO ADD MAILER FOR DECLINING APPROVAL
    OrderMailer.send_order(
      order: self, 
      status: "resubmitted_brand", 
      email: self.brand.users.pluck(:email), # send to brand/landing (currently just sending to Landing)
      subject: "#{self.orderer_company_name} has requested changes to an order on Landing!",
      title: "Order Changes Requested"
      ).deliver
    OrderMailer.send_order(
      order: self, 
      status: "resubmitted_brand", 
      email: "orders@landingintl.com", # send to brand/landing (currently just sending to Landing)
      subject: "#{self.orderer_company_name} has requested changes to an order on Landing!",
      title: "Order Changes Requested"
      ).deliver
  end

  def approval
    if self.orderer.disable_armor_payments # remove all armor ids if buyer turns off armor
      self.armor_buyer_account_id = nil if self.armor_buyer_account_id.present?
      self.armor_buyer_user_id = nil if self.armor_buyer_user_id.present?
      self.armor_buyer_email = nil if self.armor_buyer_email.present?
      self.armor_seller_account_id = nil if self.armor_seller_account_id.present?
      self.armor_seller_user_id = nil if self.armor_seller_user_id.present?
      self.armor_seller_email = nil if self.armor_seller_email.present?
    elsif self.armor_enabled?
      self.api_create_order
    end
    unless self.errors.any?
      self.status = "approved"
      self.approved_date = DateTime.now
      self.save!
    end
  end

  def paid
    return if self.status == "paid" # exit if already set
    self.status = "paid"
    self.paid_date = DateTime.now
    self.save!
    OrderMailer.send_order(
      order: self,
      status: "paid",
      email: self.brand.users.pluck(:email), # send to brand/landing (currently just sending to Landing)
      subject: "Yay! Get ready to ship!",
      title: "Order Paid"
      ).deliver
    OrderMailer.send_order(
      order: self,
      status: "paid",
      email: "orders@landingintl.com", # send to brand/landing (currently just sending to Landing)
      subject: "Yay! Get ready to ship!",
      title: "Order Paid"
      ).deliver
  end

  def shipped
    return if self.status == "shipped" # exit if already set
    self.status = "shipped"
    self.shipped_date = DateTime.now
    self.save!
    OrderMailer.send_order(
      order: self,
      status: "shipped",
      email: self.orderer.users.pluck(:email), # send to orderer email
      subject: "Hooray! Your beauty products are on their way!",
      title: "Order Shipped"
      ).deliver
  end

  def delivered
    return if self.status == "delivered" # exit if already set
    self.status = "delivered"
    self.delivered_date = DateTime.now
    self.save!
    if self.armor_enabled?
      OrderMailer.send_order(
        order: self,
        status: "delivered_orderer",
        email: self.orderer.users.pluck(:email), # send to orderer email
        subject: "Woohoo! Your order was delivered.",
        title: "Order Delivered"
        ).deliver
    end
    OrderMailer.send_order(
      order: self,
      status: "delivered_brand",
      email: self.brand.users.pluck(:email), # send to brand/landing (currently just sending to Landing)
      subject: "Nice Job! Your order was delivered.",
      title: "Order Delivered"
      ).deliver
    OrderMailer.send_order(
      order: self,
      status: "delivered_brand",
      email: "orders@landingintl.com", # send to brand/landing (currently just sending to Landing)
      subject: "Nice Job! Your order was delivered.",
      title: "Order Delivered"
      ).deliver
  end

  def disputed(dispute_id:)
    return if self.status == "disputed" # exit if already set
    self.status = "disputed"
    self.armor_dispute_id = dispute_id
    self.disputed_date = DateTime.now
    self.save!
    OrderMailer.send_order(
      order: self,
      status: "dispute_initiated",
      email: self.brand.users.pluck(:email), # send to brand/landing (currently just sending to Landing)
      subject: "Order in Dispute",
      title: "Order in Dispute"
      ).deliver
    OrderMailer.send_order(
      order: self,
      status: "dispute_initiated",
      email: "orders@landingintl.com", # send to brand/landing (currently just sending to Landing)
      subject: "Order in Dispute",
      title: "Order in Dispute"
      ).deliver
  end

  def dispute_update
    OrderMailer.send_order(
      order: self,
      status: "dispute_updated",
      email: self.brand.users.pluck(:email), # send to brand/landing (currently just sending to Landing)
      subject: "Order Dispute Updated",
      title: "Order Dispute Updated"
      ).deliver
    OrderMailer.send_order(
      order: self,
      status: "dispute_updated",
      email: "orders@landingintl.com", # send to brand/landing (currently just sending to Landing)
      subject: "Order Dispute Updated",
      title: "Order Dispute Updated"
      ).deliver
    OrderMailer.send_order(
      order: self,
      status: "dispute_updated",
      email: self.orderer.users.pluck(:email), # send to orderer
      subject: "Order Dispute Updated",
      title: "Order Dispute Updated"
      ).deliver
  end

  def completed
    return if self.status == "completed" # exit if already set
    self.status = "completed"
    self.completed_date = DateTime.now
    self.save!
    OrderMailer.send_order(
      order: self,
      status: "completed",
      email: self.brand.users.pluck(:email), # send to brand/landing (currently just sending to Landing)
      subject: "Woohoo! Your payment has been released!",
      title: "Order Payment Released"
      ).deliver
    OrderMailer.send_order(
      order: self,
      status: "completed",
      email: "orders@landingintl.com", # send to brand/landing (currently just sending to Landing)
      subject: "Woohoo! Your payment has been released!",
      title: "Order Payment Released"
      ).deliver
  end

  def completed_no_armor
    return if self.status == "completed" # exit if already set
    self.status = "completed"
    self.completed_date = DateTime.now
    self.save!
  end

  def error(status:, message:)
    self.status = "error"
    self.status_error_message = "Status #{status}: #{message}"
    self.error_date = DateTime.now
    self.save!
    OrderMailer.send_order(
      order: self,
      status: "error",
      email: self.orderer.users.pluck(:email), # send to orderer email
      subject: "Landing International: Order Completed",
      title: "Order Errors"
      ).deliver
    OrderMailer.send_order(
      order: self,
      status: "error",
      email: self.brand.users.pluck(:email), # send to brand/landing (currently just sending to Landing)
      subject: "Landing International: Order Errors",
      title: "Order Errors"
      ).deliver
    OrderMailer.send_order(
      order: self,
      status: "error",
      email: "orders@landingintl.com", # send to brand/landing (currently just sending to Landing)
      subject: "Landing International: Order Errors",
      title: "Order Errors"
      ).deliver
  end

  def viewable_by?(user)
    return true if self.orderer == user.company || self.brand == user.company
  end

  def generate_id(column)
    numberstring = Order.all.count + 1000 # lets start at 1000!
    begin
      numberstring += 1
      self[column] = "LAN" + numberstring.to_s
    end while Order.where(column => self[column]).exists?
  end

end
