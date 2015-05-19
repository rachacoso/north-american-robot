class ChannelCapacity
  include Mongoid::Document
  field :channel_id, type: String
  field :custom_channel_name, type: String
  field :capacity, type: Integer

	validates :channel_id, presence: true

  belongs_to :brand
  belongs_to :distributor 
end
