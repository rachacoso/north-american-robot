class OrderItem # for V2 ordering
  include Mongoid::Document
	include Mongoid::Timestamps::Short
  
  embedded_in :order

  field :quantity, type: Integer, default: nil
  field :quantity_testers, type: Integer, default: nil

  field :name, type: String, default: ""
  field :price, type: Integer # store MSRP price as cents (to be used in calculations for orders)
  field :item_id, type: String, default: ""
  field :item_size, type: String, default: ""
  field :product_id, type: BSON::ObjectId
  field :packing_list_id, type: BSON::ObjectId # packing list that this item has been shipped in

  scope :sent, ->{where(:packing_list_id.nin => ["", nil])}  
  scope :unsent, ->{where(:packing_list_id.in => ["", nil])}

  def self.get_item(product:, orderer:)
    order = Order.current.where(brand: product.brand, orderer: orderer).first
    if order && item = order.order_items.find_by(product_id: product.id)
      return item
    else
      return self.new
    end
  end

  def product
  	return Product.find(self.product_id)
  end
  def price_in_dollars # convert from the stored price in cents
    return (self.price.to_f / 100)
  end
  def tiered_price_in_dollars # convert from the stored price in cents (default 50%)
    return ((self.price.to_f * (1-(self.order.discount.to_f / 100))) / 100)
  end
  def tiered_price # convert from the stored price in cents (default 50%)
    return (self.price * (1-(self.order.discount.to_f/100)))
  end
  def total_price # in dollars
    if self.quantity.blank?
      return nil
    else
      return ((self.quantity * self.tiered_price) / 100)
    end
  end

  def can_be_edited(controller:, user:)
    return false if controller == "home"
    if self.order.status == "open" && !user.brand
      return true
    elsif self.order.status == "submitted" && user.brand
      return true
    end
  end
end
