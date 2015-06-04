class Match
  include Mongoid::Document
	include Mongoid::Timestamps::Short

	belongs_to :distributor
	belongs_to :brand

  field :initial_contact_by, type: String

  # is the match accepted by contactee
  field :accepted, type: Mongoid::Boolean
  field :intro_message, type: String
  field :stage, type: String, default: "contact"  # stage: [contact,prepare,terms,order]

  has_many :messages, dependent: :destroy
end
