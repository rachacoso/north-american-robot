class Message
  include Mongoid::Document
	include Mongoid::Timestamps::Created::Short
  
  belongs_to :match
  
  # id of distributor/brand match
  field :recipient, type: String
  field :subject, type: String
  field :text, type: String
  field :read, type: Mongoid::Boolean

  field :stage, type: String  # stage: [contact,propose,prepare,order]
  
end
