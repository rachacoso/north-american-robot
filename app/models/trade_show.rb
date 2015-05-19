class TradeShow
  include Mongoid::Document
  belongs_to :distributor
  belongs_to :brand

  field :name, type: String, default: ""
  field :date, type: Date, default: -> { DateTime.now }
  field :country, type: String, default: ""
  field :years_participated, type: String, default: ""
  field :website, type: String, default: ""  
end
