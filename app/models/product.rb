class Product
  include Mongoid::Document
	include Mongoid::Timestamps::Short
	
 	field :name, type: String, default: ""
 	field :description, type: String, default: ""
 	field :msrp, type: String, default: "" # old version & now will be used for display purposes only
 	field :price, type: Integer # store MSRP price as cents (to be used in calculations for orders)
 	field :item_id, type: String, default: ""
 	field :item_size, type: String, default: ""
 	field :key_benefits, type: String, default: ""
 	field :ingredients, type: String, default: ""
 	field :country_of_manufacture, type: String, default: ""
 	field :current, type: Mongoid::Boolean

 	has_many :inventory_adjustments

 	has_many :product_photos, as: :photographable, dependent: :destroy
	has_many :tags, as: :taggable, dependent: :destroy

 	belongs_to :brand

 	scope :featureable, ->{where(current: true)}
  
  def inventory
  	return self.inventory_adjustments.received.sum(:units) - self.inventory_adjustments.deducted.sum(:units)
  end

  def inventory_new
  	bought = self.brand.orders.with_inventory_deductions(self).map! { |o| o.order_items.find_by(product_id: self.id).quantity }.map {|e| e ? e : 0}.inject(0){|sum,x| sum + x }
  	testers = self.brand.orders.with_inventory_deductions(self).map! { |o| o.order_items.find_by(product_id: self.id).quantity_testers }.map {|e| e ? e : 0}.inject(0){|sum,x| sum + x }
  	return self.inventory_adjustments.received.sum(:units) - ( bought + testers )
  end

  def inventory_less_on_hold
  	bought = self.brand.orders.with_inventory_hold(self).map! { |o| o.order_items.find_by(product_id: self.id).quantity }.map {|e| e ? e : 0}.inject(0){|sum,x| sum + x }
  	testers = self.brand.orders.with_inventory_hold(self).map! { |o| o.order_items.find_by(product_id: self.id).quantity_testers }.map {|e| e ? e : 0}.inject(0){|sum,x| sum + x }
  	return self.inventory - ( bought + testers )
  end

	def save_price(p)
		unless p.blank?
			pc = (p.to_f * 100).round
			self.price = pc
			self.save!
		end
	end

	def price_in_dollars # convert from the stored price in cents
		return '%.2f' % (self.price.to_f / 100)
	end

	def tiered_price_in_dollars(discount=50) # convert from the stored price in cents (default 50%)
		return '%.2f' % ((self.price.to_f * (1-(discount.to_f/100))) / 100)
	end

	def tiered_price(discount=50) # convert from the stored price in cents (default 50%)
		return (self.price * (1-(discount.to_f/100)))
	end

	def name_with_id
		return "#{self.item_id} - #{self.name}"
	end
end