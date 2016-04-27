require 'ffaker'
FactoryGirl.define do
  factory :address do

		address1 { FFaker::AddressUS.street_address }
		address2 { FFaker::AddressUS.secondary_address }
		city { FFaker::AddressUS.city }
		state { FFaker::AddressUS.state_abbr }
		postcode { FFaker::AddressUS.state_abbr }
		country { FFaker::Address.country }
  end
end