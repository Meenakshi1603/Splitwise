FactoryBot.define do
  factory :expense_split do
    association :user
    association :expense
    amount {Faker::Number}
  end
end