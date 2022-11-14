class AddAdditionalHourDateToAdditionalHour < ActiveRecord::Migration[7.0]
  def change
    add_column :additional_hours, :additional_hour_date, :date
    add_column :additional_hours, :comment, :text
  end
end
