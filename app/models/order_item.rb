class OrderItem # for V2 ordering
  include Mongoid::Document
	include Mongoid::Timestamps::Short
  
  embedded_in :order

  field :quantity, type: Integer

  field :name, type: String, default: ""
  field :price, type: Integer # store MSRP price as cents (to be used in calculations for orders)
  field :item_id, type: String, default: ""
  field :item_size, type: String, default: ""
  field :product_id, type: BSON::ObjectId

  def product
  	return Product.find(self.product_id)
  end
  def price_in_dollars # convert from the stored price in cents
    return '%.2f' % (self.price.to_f / 100)
  end
  def tiered_price_in_dollars(discount=0.5) # convert from the stored price in cents (default 50%)
    return '%.2f' % ((self.price.to_f * (1-discount)) / 100)
  end
  def tiered_price(discount=0.5) # convert from the stored price in cents (default 50%)
    return (self.price * (1-discount))
  end
  def total_price # in dollars
  	return (self.quantity * self.product.tiered_price) / 100
  end

end
