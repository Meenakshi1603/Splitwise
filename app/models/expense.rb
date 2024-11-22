# frozen_string_literal: true

class Expense < ApplicationRecord
  belongs_to :group
  has_many :expense_splits, dependent: :destroy
  has_many :users, through: :expense_splits
  validates :name, :date, :amount, presence: {message: "can't be blank"}
  validates :name, uniqueness: {message: "already exists"}
  validates :amount, numericality: {greater_than: 0,mesage: "must be greater than zero"}
  validate :no_future
  belongs_to :user
  private
  

  def no_future
    if self.date.present? && date>Date.today
      errors.add(:date, "cannot be in future")
    end
  end


end
