class OrderAdditionalCharge # for V2 ordering
  include Mongoid::Document
	include Mongoid::Timestamps::Short
  
  embedded_in :order

	field :amount, type: Integer # store MSRP price as cents (to be used in calculations for orders)
  field :name, type: String, default: ""
  field :description, type: String

  validates :name, presence: true
  validates :amount, presence: true


	def set_amount(c)
		unless c.blank?
			self.amount = (c.to_f * 100).round
			self.save!
		end
	end

  def amount_in_dollars # convert from the stored price in cents
    return (self.amount.to_f / 100)
  end

end