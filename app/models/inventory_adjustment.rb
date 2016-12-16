class InventoryAdjustment
  include Mongoid::Document
	include Mongoid::Timestamps::Created::Short
  
  belongs_to :product
  
  field :units, type: Integer
  field :type, type: String # requested, sent, received, deducted
  field :comment, type: String

	validates :units, presence: true
	validates :type, presence: true

  scope :received, ->{where(type: "received")}
  scope :deducted, ->{where(type: "deducted")}

end
