class PackingList # for V2 ordering
	include Mongoid::Document
	include Mongoid::Timestamps::Short

	belongs_to :retailer

	field :po_number, type: String # PO number ( equivalent to order.rb > :orderer_order_reference_id )



end