class Subsector
  include Mongoid::Document
  field :name, type: String
  validates :name, presence: true
  belongs_to :sector
end