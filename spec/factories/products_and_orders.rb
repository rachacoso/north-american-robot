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
  end

end

FactoryGirl.define do

  factory :order_additional_charge do
    amount { Random.rand(1000..30000) }
    name  { FFaker::Lorem.sentence }
    description { FFaker::Lorem.phrase }
    order
  end


end
