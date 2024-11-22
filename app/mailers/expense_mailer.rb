# frozen_string_literal: true

class ExpenseMailer < ApplicationMailer
  default from: 'meenakshipandey1603@gmail.com'
  def new_expense_notification(expense, user)
    @expense = expense
    @user = user
    mail(to: @user.email, subject: 'New Expense has been Added')
  end
end
