# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :groups
  has_many :memberships
  has_many :group_memberships, through: :memberships, source: :group
  has_many :expense_splits
end
