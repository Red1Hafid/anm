class AddBalanceOpenAdditionalHourToBank < ActiveRecord::Migration[7.0]
  def change
    add_column :banks, :balance_open_additional_hour, :integer
  end
end
