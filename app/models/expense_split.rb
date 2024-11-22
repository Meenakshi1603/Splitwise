# frozen_string_literal: true

class ExpenseSplit < ApplicationRecord
  belongs_to :user
  belongs_to :expense

  scope :owed, lambda { |user|
    where('expense_splits.user_id != ? AND expense_splits.amount > 0', user.id).joins(:expense).where(expenses: { user_id: user.id }).group('expense_splits.user_id').sum('expense_splits.amount')
  }

  scope :debt, ->(user) { joins(:expense).where(user_id: user.id).where.not(expenses: { user_id: user.id }).group('expenses.user_id').sum('expense_splits.amount') }
end
