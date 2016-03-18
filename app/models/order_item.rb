class OrderItem # for V2 ordering
  include Mongoid::Document
	include Mongoid::Timestamps::Created::Short
  
  embedded_in :order

  field :quantity, type: Integer
  field :product_id, type: BSON::ObjectId
end
