class Contact
  include Mongoid::Document

  field :firstname, type: String # WAS part of contact_name
  field :lastname, type: String # WAS part of contact_name
  field :title, type: String # WAS contact_title
  field :email, type: String
  field :phone, type: String

  embeds_one :address, as: :addressable
  accepts_nested_attributes_for :address

  belongs_to :contactable, polymorphic: true

end
