# frozen_string_literal: true

class Group < ApplicationRecord
  belongs_to :user
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :expenses, dependent: :destroy

  validates :name, uniqueness: { message: "already exists" }
  validates :name, presence: { message: "can't be blank" }
end
