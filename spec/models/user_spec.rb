require 'rails_helper'

RSpec.describe User, type: :model do
  it { should validate_length_of(:password).is_at_least(6) }
  it { should validate_presence_of(:password) }
  it { should validate_presence_of(:email) }
  it 'is invalid without a password' do
    user = build(:user, password: nil)
    expect(user).not_to be_valid
  end
  it { should have_many(:groups) }
  it { should have_many(:memberships) }
  it { should have_many(:group_memberships).through(:memberships).source(:group) }
  it { should have_many(:expense_splits) }
end
