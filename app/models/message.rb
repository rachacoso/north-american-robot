class Message
  include Mongoid::Document
	include Mongoid::Timestamps::Created::Short
  
  belongs_to :match
  
  # id of distributor/brand match
  field :sender, type: String
  field :sender_email, type: String # for simple_message
  field :recipient, type: BSON::ObjectId # for simple_message
  field :subject, type: String
  field :text, type: String
  field :read, type: Mongoid::Boolean

  field :stage, type: String  # stage: [contact,propose,prepare,order]
  
  # log who sent it
  belongs_to :user

  def simple_messages
    MessageMailer.send_simple_messages(self)
  end
end
