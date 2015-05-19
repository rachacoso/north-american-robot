class Patent
  include Mongoid::Document

  belongs_to :brand

  field :product, type: String, default: ""
  field :patent_description, type: String, default: ""
  field :country, type: String, default: ""
  field :date, type: Date, default: -> { DateTime.now }
  field :status, type: String, default: ""
  
end
