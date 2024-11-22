# frozen_string_literal: true

class AddDateToExpenses < ActiveRecord::Migration[7.1]
  def change
    add_column :expenses, :date, :date
  end
end
