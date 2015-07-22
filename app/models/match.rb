class Match
  include Mongoid::Document
	include Mongoid::Timestamps::Short

	belongs_to :distributor
	belongs_to :brand

  field :initial_contact_by, type: String

  # is the match accepted by contactee
  field :accepted, type: Mongoid::Boolean
  field :intro_message, type: String
  field :stage, type: String, default: "contact"  # stage: [contact,propose,prepare,order]

  field :brand_proceed_to_next_stage, type: Mongoid::Boolean
  field :distributor_proceed_to_next_stage, type: Mongoid::Boolean

  field :shared_product_pricing, type: Mongoid::Boolean
  field :shared_country_requirements, type: Mongoid::Boolean

  has_many :messages, dependent: :destroy
end
