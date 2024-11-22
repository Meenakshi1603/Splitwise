FactoryBot.define do
  factory :group do
    name { Faker::Internet.domain_name }
    association :user
  end
end
