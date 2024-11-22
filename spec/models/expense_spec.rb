require 'rails_helper'

RSpec.describe Expense, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:date) }
  it { should validate_presence_of(:amount) }
  it { should validate_numericality_of(:amount).is_greater_than(0) }
  it { should have_many(:expense_splits) }
  it { should have_many(:users) }
  it 'gives error if the date is in the future' do
    expense = build(:expense, date: Date.tomorrow)
    expect(expense).not_to be_valid
  end
end
