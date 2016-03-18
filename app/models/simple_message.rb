class SimpleMessage # for V2 simple messaging (separate from previously created messaging system)
  include Mongoid::Document
	include Mongoid::Timestamps::Created::Short
  
  # who is message to
  belongs_to :brand
  # log who sent it
  belongs_to :user

  # id of distributor/brand match
  field :recipient, type: String
  field :subject, type: String
  field :text, type: String
end