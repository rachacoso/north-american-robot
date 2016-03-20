class OrderItem # for V2 ordering
  include Mongoid::Document
	include Mongoid::Timestamps::Short
  
  embedded_in :order

  field :quantity, type: Integer
  field :product_id, type: BSON::ObjectId

  def product
  	return Product.find(self.product_id)
  end
  def total_price # in dollars
  	return (self.quantity * self.product.tiered_price) / 100
  end

end
