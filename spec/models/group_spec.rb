require 'rails_helper'

RSpec.describe Group, type: :model do
  it {should validate_presence_of (:name)}
  it {should have_many(:memberships)}
  it {should have_many(:users) }
  it {should have_many(:expenses) }
end