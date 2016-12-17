class InventoryAdjustment
  include Mongoid::Document
	include Mongoid::Timestamps::Created::Short
  
  belongs_to :product
  
  field :units, type: Integer
  field :type, type: String # requested, sent, received, deducted
  field :comment, type: String
  field :order_id, type: BSON::ObjectId # for deductions, indicate which order 

	validates :units, presence: true
	validates :type, presence: true
  validates_presence_of :order_id, :if => Proc.new { |o| o.type == "deducted"}

  scope :received, ->{where(type: "received")}
  scope :deducted, ->{where(type: "deducted")}
  scope :from_order, ->(order_id) {where(order_id: order_id)}

  def order
    return Order.find(self.order_id) if self.order_id.present?
  end
end
