

class UsersController < ApplicationController
  before_action :authenticate_user!

  def profile
    @amounts_owed_to_you = calculate_amounts_owed(current_user)
    @debts = calculate_user_debts(current_user)

    @net_balances = calculate_net_balances(@amounts_owed_to_you, @debts)
  end

  private

  def calculate_amounts_owed(user)
    ExpenseSplit.owed(user)
  end

  def calculate_user_debts(user)
    ExpenseSplit.debt(user)
  end

  def calculate_net_balances(amounts_owed_to_you, debts)
    net_balances = Hash.new(0)

    amounts_owed_to_you.each do |user_id, amount|
      net_balances[user_id] = net_balances[user_id]+amount
    end

    debts.each do |user_id, amount|
      net_balances[user_id] =net_balances[user_id]- amount
    end

    net_balances.reject { |_, net_amount| net_amount.zero? }
  end
end
