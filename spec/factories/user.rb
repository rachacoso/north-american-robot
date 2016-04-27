require 'ffaker'
FactoryGirl.define do

  factory :user do
    email { FFaker::Internet.email }
    contact
    password '123'
    password_confirmation '123'
    factory :administrator do
      administrator true
    end
    factory :brand_user do
      brand
      company { brand }
    end
    factory :retailer_user do
      retailer
      company { retailer }
    end
    factory :distributor_user do
      distributor
      company { distributor }
    end
  end

end