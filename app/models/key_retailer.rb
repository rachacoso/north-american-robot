class KeyRetailer
  include Mongoid::Document
  field :name, type: String
  validates :name, presence: true, uniqueness: true

end