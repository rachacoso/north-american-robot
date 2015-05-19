class Compliance
  include Mongoid::Document

  field :product_or_category, type: String, default: ""
  field :compliance_description, type: String, default: ""
  field :country, type: String, default: ""
  field :date, type: Date, default: -> { DateTime.now }
  field :status, type: String, default: ""

  belongs_to :brand

end
