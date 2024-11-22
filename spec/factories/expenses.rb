FactoryBot.define do
  factory :expense do
    name {Faker::Internet.name }
    date {Faker::Date.backward(days: 30) }
    amount {Faker::Number.positive}#Internet doesnt have number method
    association :group
    association :user
  end
end
