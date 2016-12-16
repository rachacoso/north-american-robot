class InventoryAdjustment
  include Mongoid::Document
	include Mongoid::Timestamps::Created::Short
  
  belongs_to :product
  
  field :units, type: Integer
  field :type, type: String # requested, sent, received, deducted
  field :comment, type: String

  scope :received, ->{where(type: "received")}
  scope :deducted, ->{where(type: "deducted")}

end
