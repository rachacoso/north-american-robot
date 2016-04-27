require 'ffaker'


FactoryGirl.define do

  factory :product do
    name { FFaker::Product.product_name }
    description { FFaker::Lorem.paragraph }
    price { Random.rand(100..30000) }
    item_id { FFaker::Product.model }
    item_size { FFaker::Lorem.word }
    key_benefits { FFaker::Lorem.phrases }
    country_of_manufacture { FFaker::Address.country }
    current true
    brand
  end

  factory :order do
    brand
    brand_company_name { brand.company_name }
    status "open"

    factory :retailer_order do
      association :orderer, factory: :retailer
      orderer_company_name { orderer.company_name }
    end
    factory :distributor_order do
      association :orderer, factory: :distributor
      orderer_company_name { orderer.company_name }
    end

    trait :with_charges do
      transient do
        charges_count 3
      end
      after(:create) do |order, evaluator|
        create_list(:order_additional_charge, evaluator.charges, order: order)
      end
    end

  end
  
end
