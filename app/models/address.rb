class Address
  include Mongoid::Document
  field :address1, type: String
  field :address2, type: String
  field :city, type: String
  field :state, type: String
  field :postcode, type: String
  field :country, type: String

  embedded_in :addressable, polymorphic: true
  
end
