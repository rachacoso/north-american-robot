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

  field :brand_shared_propose, type: Mongoid::Boolean
  field :distributor_shared_propose, type: Mongoid::Boolean

  # CONTRACT FIELDS
  # BRAND
  # documents
  field :tiered_pricing_schedule, type: String
  field :fob_pricing, type: String
  field :products_list, type: String
  # text fields
  field :partnership_terms_length, type: String
  field :payment_terms, type: String
  field :grant_territory_exclusivity, type: String
  field :requested_minimum_marketing_spend, type: String
  field :marketing_requests_or_requirements, type: String
  field :sales_channel_requests_or_requirements, type: String

  # DISTRIBUTOR
  # text fields
  field :brand_launch_plan, type: String
  field :marketing_strategy, type: String
  field :initial_channels, type: String
  field :second_tier_channels, type: String
  field :third_tier_channels, type: String
  field :minimum_volume_year_one, type: String
  field :minimum_volume_year_two, type: String
  field :minimum_volume_year_three, type: String


  has_many :messages, dependent: :destroy

end
