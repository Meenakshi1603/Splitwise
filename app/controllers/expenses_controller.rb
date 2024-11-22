# frozen_string_literal: true

class ExpensesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :set_expense, only: [:destroy]

  def index
    @expenses = @group.expenses.includes(expense_splits: :user)

    @expenses = @expenses.where('name ILIKE ?', "%#{params[:search]}%") if params[:search].present?

    @expenses = @expenses.where(date: params[:date]) if params[:date].present?

    return unless params[:amount].present?

    @expenses = @expenses.where(amount: params[:amount])
  end

  def destroy
    @expense.destroy!
    redirect_to group_expenses_path(@group), notice: 'Expense  deleted.'
  end

  def new
    @expense = Expense.new
    @users = @group.users
  end

  def create
    @expense = @group.expenses.new(expense_params)
    @expense.user_id = current_user.id
    if @expense.save
      ExpenseMailer.new_expense_notification(@expense, current_user).deliver_now

      if params[:split_type] == 'equal'
        split_equal
      else
        split_unequal
      end

      redirect_to group_expenses_path(@group), notice: 'Expense created'
    else
      @users = @group.users
      flash.now[:alert] = @expense.errors.full_messages.join(', ')
      render :new
    end
  end

  private

  def set_group
    @group = Group.find(params[:group_id])
  end

  def set_expense
    @expense = @group.expenses.find_by(id: params[:id])
    return if @expense

    redirect_to group_expenses_path(@group), alert: 'Expense not found.'
  end

  def expense_params
    params.require(:expense).permit(:name, :amount, :date)
  end

  def split_equal
    split_amount = @expense.amount / @group.users.count

    @group.users.each do |user|
      @expense.expense_splits.create!(user: user, amount: split_amount)
    end
  end

  def split_unequal
    params[:user_ids].each do |user_id|
      amount = params[:amounts][user_id].to_d
      @expense.expense_splits.create!(user_id: user_id, amount: amount)
    end
  end
end
