require 'ffaker'
FactoryGirl.define do
  factory :contact do
    firstname { FFaker::Name.first_name }
    lastname { FFaker::Name.last_name }
    title { FFaker::Job.title }
    phone FFaker::PhoneNumber.short_phone_number
  end

end