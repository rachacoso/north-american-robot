class InventoryAdjustment
  include Mongoid::Document
	include Mongoid::Timestamps::Short
  
  belongs_to :product
  
  field :units, type: Integer
  field :type, type: String # requested, shipment, received, deducted
  field :comment, type: String
  field :order_id, type: BSON::ObjectId # for deducted, indicate which order
  field :complete, type: Mongoid::Boolean, default: false # for REQUESTED keep record of shipped units
  field :ship_date, type: Date
  # for shipment, indicate which InventoryAdjustment 'request' it is for,
  # for requested or received, indicate which InventoryAdjustment 'shipment' it is for
  has_and_belongs_to_many :associated_requests, class_name: "InventoryAdjustment", inverse_of: nil
  has_and_belongs_to_many :associated_shipments, class_name: "InventoryAdjustment", inverse_of: nil
  has_and_belongs_to_many :associated_received_shipments, class_name: "InventoryAdjustment", inverse_of: nil

	validates :units, presence: true
	validates :type, presence: true
  validates_presence_of :order_id, :if => Proc.new { |o| o.type == "deducted"}
  validates_presence_of :ship_date, :if => Proc.new { |o| o.type == "shipment"}

  scope :received, ->{where(type: "received")}
  scope :deducted, ->{where(type: "deducted")}
  scope :of_type, ->(type) {where(type: type)}
  scope :from_order, ->(order_id) {where(order_id: order_id)}
  scope :of_products, ->(product_ids) {where(:product_id.in => product_ids)}
  scope :unfulfilled_requests, ->{where(type: "requested",complete: false)}
  scope :unfulfilled_shipments, ->{where(type: "shipment",:associated_received_shipment_ids.in => ["", nil, []])}

  def order
    return Order.find(self.order_id) if self.order_id.present?
  end
  def complete?
    if self.type == "requested" && self.complete
      return true 
    elsif self.type == "shipment" && self.associated_received_shipments.present?
      return true
    end
  end
  def shipment_add_associated(adjustments)
    adjustments.each do |id,v|
      if v == "true"
        if a = InventoryAdjustment.find(id)
          self.associated_requests << a
          a.associated_shipments << self
          a.update_completeness
        end
      elsif v == "false"
        if a = InventoryAdjustment.find(id)
          self.associated_requests.delete(a)
          a.associated_shipments.delete(self)
          a.update_completeness
        end
      end
    end
  end
  def received_shipment_add_associated(adjustments)
    adjustments.each do |id,v|
      if v == "true"
        if a = InventoryAdjustment.find(id)
          self.associated_shipments << a
          a.associated_received_shipments << self
        end
      elsif v == "false"
        if a = InventoryAdjustment.find(id)
          self.associated_shipments.delete(a)
          a.associated_received_shipments.delete(self)
        end
      end
    end
  end
  def update_completeness
    if self.type == "requested"
      if self.units <= self.associated_shipments.sum(:units)
        self.complete = true 
      else
        self.complete = false
      end
      self.save!
    end
  end
  def cache_previous_data
    @previous_data = Hash.new
    @previous_data[:update_date] = self.u_at
    @previous_data[:units] = self.units
    @previous_data[:comment] = self.comment
    if self.type == "requested"
      @previous_data[:associated_shipments] = self.associated_shipments
    elsif self.type == "shipment"
      @previous_data[:ship_date] = self.ship_date
      @previous_data[:associated_requests] = self.associated_requests
      @previous_data[:associated_received_shipments] = self.associated_received_shipments
    end
  end
  def mailer_send_notice
    return if self.type == "received"
    if self.type == "requested"
      type = "request"
      subject = "Landing International has requested an inventory shipment"
      title = "Inventory Request"
      email = self.product.brand.users.pluck(:email)
    elsif self.type == "shipment"
      type = "shipment"
      subject = "#{self.product.brand.company_name} has sent an inventory shipment"
      title = "Inventory Shipment"
      email = "info@landingintl.com"
    end
    begin
    InventoryAdjustmentMailer.send_notice(
      type: type,
      adjustment: self,
      subject: subject,
      title: title,
      email: email
    ).deliver
    rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e
      self.errors.add(:base, e.message)
    end
  end
  def mailer_send_update_notice
    return if self.type == "received"
    if self.type == "requested"
      type = "request_updated"
      subject = "Landing International has updated an inventory shipment request"
      title = "Inventory Request Updated"
      email = self.product.brand.users.pluck(:email)
    elsif self.type == "shipment"
      type = "shipment_updated"
      subject = "#{self.product.brand.company_name} has updated an inventory shipment"
      title = "Inventory Shipment Updated"
      email = "info@landingintl.com"
    end
    begin
    InventoryAdjustmentMailer.send_notice(
      type: type,
      adjustment: self,
      previous_data: @previous_data, 
      subject: subject,
      title: title,
      email: email
    ).deliver
    rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e
      self.errors.add(:base, e.message)
    end
  end
end
