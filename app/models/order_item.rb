class OrderItem # for V2 ordering
  include Mongoid::Document
	include Mongoid::Timestamps::Created::Short
  
  belongs_to :order

  field :quantity, type: Integer
  embeds_one :product
end
