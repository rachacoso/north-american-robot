class Channel
  include Mongoid::Document
  field :name, type: String
  field :description, type: String
  validates :name, presence: true, uniqueness: true
  
end
