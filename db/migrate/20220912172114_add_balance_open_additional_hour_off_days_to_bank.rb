class AddBalanceOpenAdditionalHourOffDaysToBank < ActiveRecord::Migration[7.0]
  def change
    add_column :banks, :balance_open_additional_hour_off_days, :integer
  end
end
