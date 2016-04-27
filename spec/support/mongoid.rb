# RSpec
# spec/support/mongoid.rb
RSpec.configure do |config|
  config.include Mongoid::Matchers, type: :model
end