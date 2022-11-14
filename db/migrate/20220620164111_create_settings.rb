class CreateSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :settings do |t|
      t.float :month_balance
      t.integer :day_work_hour
    end
  end
end
