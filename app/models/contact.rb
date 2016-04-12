class Contact
  include Mongoid::Document
  include Mongoid::Phony

  field :firstname, type: String # WAS part of contact_name
  field :lastname, type: String # WAS part of contact_name
  field :title, type: String # WAS contact_title
  field :email, type: String
  field :phone, type: String

  phony_normalize :phone, default_country_code: 'US'
	validates :phone, phony_plausible: true

  embeds_one :address, as: :addressable
  accepts_nested_attributes_for :address

  belongs_to :contactable, polymorphic: true

end
