class Product
  include Mongoid::Document

 	field :name, type: String, default: ""
 	field :description, type: String, default: ""
 	field :msrp, type: String, default: "" # old version & now will be used for display purposes only
 	field :price, type: Integer # store MSRP price as cents (to be used in calculations for orders)
 	field :item_id, type: String, default: ""
 	field :item_size, type: String, default: ""
 	field :key_benefits, type: String, default: ""
 	field :country_of_manufacture, type: String, default: ""
 	field :current, type: Mongoid::Boolean

 	has_many :product_photos, as: :photographable, dependent: :destroy
	has_many :tags, as: :taggable, dependent: :destroy

 	belongs_to :brand
  
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

	def tiered_price_in_dollars(discount=0.5) # convert from the stored price in cents (default 50%)
		return '%.2f' % ((self.price.to_f * (1-discount)) / 100)
	end

	def tiered_price(discount=0.5) # convert from the stored price in cents (default 50%)
		return (self.price * (1-discount))
	end

end