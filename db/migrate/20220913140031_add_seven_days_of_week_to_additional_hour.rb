class AddSevenDaysOfWeekToAdditionalHour < ActiveRecord::Migration[7.0]
  def change
    add_column :additional_hours, :monday_quantity, :integer
    add_column :additional_hours, :tuesday_quantity, :integer
    add_column :additional_hours, :wednesday_quantity, :integer
    add_column :additional_hours, :thursday_quantity, :integer
    add_column :additional_hours, :friday_quantity, :integer
    add_column :additional_hours, :saturday_quantity, :integer
    add_column :additional_hours, :sunday_quantity, :integer
  end
end
