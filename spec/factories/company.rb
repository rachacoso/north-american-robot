require 'ffaker'
FactoryGirl.define do
  factory :brand do
		subscriber true
		active true
	 	company_name { FFaker::Company.name }
		country_of_origin { FFaker::Address.country }
		year_established { Date.new(1990) }
		address  { FactoryGirl.build(:address) }
  end
end

FactoryGirl.define do

  factory :retailer do
		subscriber true
		active true
	 	company_name { FFaker::Company.name }
		country_of_origin { FFaker::Address.country }
		year_established { Date.new(2011) }
		address  { FactoryGirl.build(:address) }
  end


  factory :distributor do
		subscriber true
		active true
	 	company_name { FFaker::Company.name }
		country_of_origin { FFaker::Address.country }
		year_established { Date.new(1980) }
		address  { FactoryGirl.build(:address) }
  end

end