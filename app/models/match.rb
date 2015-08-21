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
  field :tiered_pricing_schedule, type: Array, default: []
  field :fob_pricing, type: Array, default: []
  field :products_list, type: Array, default: []
  field :certification_information_documents, type: Array, default: []
  field :patent_information_documents, type: Array, default: []
  field :testing_information_documents, type: Array, default: []
  field :ingredient_or_materials_lists, type: Array, default: []

  # text fields
  field :partnership_start_date, type: Date
  field :partnership_terms_length, type: String, default: "3 years"
  field :renewal_terms, type: String, default: ""
  field :termination_terms, type: String, default: ""
  field :payment_terms, type: String, default: ""
  field :territory_exclusivity_terms, type: String, default: ""
  field :requested_minimum_marketing_spend, type: String, default: ""
  field :marketing_requests_or_requirements, type: String, default: ""
  field :retail_channel_requests_or_requirements, type: String, default: ""
  field :order_turnaround, type: String, default: ""
  field :pricing_amendments, type: String, default: ""

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
  field :labeling_information, type: String, default: ""
  field :tariffs_information, type: String, default: ""
  field :contract_authentication, type: String, default: ""
  field :shipping, type: String, default: ""
  field :channel_rights, type: String, default: ""
  field :marketing_commitments, type: String, default: ""

  field :account_executive, type: String, default: ""
  field :warehouse_contact, type: String, default: ""
  field :freight_forwarder, type: String, default: ""

  #checkboxes
  field :territory, type: Array, default: []
  field :initial_channels, type: Array, default: []
  field :second_tier_channels, type: Array, default: []
  field :third_tier_channels, type: Array, default: []
  field :marketing_channels, type: Array, default: []
  field :skus_for_testing, type: Hash, default: {}

  has_many :messages, dependent: :destroy

  def get_b_or_d(current_user)
    return self.send(current_user.type_inverse?)
  end
end
