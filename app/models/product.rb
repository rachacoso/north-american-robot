class Product
  include Mongoid::Document

 	field :name, type: String, default: ""
 	field :description, type: String, default: ""
 	field :msrp, type: String, default: "" # old version & now will be used for display purposes only
 	field :price, type: Integer # store MSRP price as cents (to be used in calculations for orders)
 	field :key_benefits, type: String, default: ""
 	field :country_of_manufacture, type: String, default: ""
 	field :current, type: Mongoid::Boolean

 	has_many :product_photos, as: :photographable, dependent: :destroy
	has_many :tags, as: :taggable, dependent: :destroy

 	belongs_to :brand
  
end
