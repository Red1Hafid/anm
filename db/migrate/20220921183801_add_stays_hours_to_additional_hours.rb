class AddStaysHoursToAdditionalHours < ActiveRecord::Migration[7.0]
  def change
    add_column :additional_hours, :stay_hours, :integer
  end
end
