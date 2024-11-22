require 'rails_helper'
RSpec.describe ExpenseSplit, type: :model do
  it {should belong_to(:user) }
  it {should belong_to(:expense)}
end