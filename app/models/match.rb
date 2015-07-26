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
  field :brand_shared_prepare, type: Mongoid::Boolean
  field :distributor_shared_prepare, type: Mongoid::Boolean

  # CONTRACT FIELDS
  # BRAND
  # documents
  field :tiered_pricing_schedule, type: String, default: ""
  field :fob_pricing, type: String, default: ""
  field :products_list, type: String, default: ""
  field :certification_information_documents, type: String, default: ""
  field :patent_information_documents, type: String, default: ""
  field :testing_information_documents, type: String, default: ""
  field :ingredient_or_materials_lists, type: String, default: ""

  # text fields
  field :partnership_terms_length, type: String, default: "3 years"
  field :payment_terms, type: String, default: ""
  field :grant_territory_exclusivity, type: String, default: ""
  field :requested_minimum_marketing_spend, type: String, default: ""
  field :marketing_requests_or_requirements, type: String, default: ""
  field :sales_channel_requests_or_requirements, type: String, default: ""

  # DISTRIBUTOR
  # text fields
  field :brand_launch_plan, type: String, default: ""
  field :marketing_strategy, type: String, default: ""
  field :minimum_volume_year_one, type: String, default: ""
  field :minimum_volume_year_two, type: String, default: ""
  field :minimum_volume_year_three, type: String, default: ""
  field :testing_information, type: String, default: ""
  field :certification_information, type: String, default: ""
  field :customs_information, type: String, default: ""
  field :tariffs_information, type: String, default: ""
  field :contract_authentication, type: String, default: ""

  #checkboxes
  field :initial_channels, type: Array, default: []
  field :second_tier_channels, type: Array, default: []
  field :third_tier_channels, type: Array, default: []
  field :marketing_channels, type: Array, default: []

  has_many :messages, dependent: :destroy

end
