class Sector
  include Mongoid::Document
  field :name, type: String
  validates :name, presence: true, uniqueness: true

	has_many :subsectors
	accepts_nested_attributes_for :subsectors

end
