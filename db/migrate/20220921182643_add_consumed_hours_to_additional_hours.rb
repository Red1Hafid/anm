class AddConsumedHoursToAdditionalHours < ActiveRecord::Migration[7.0]
  def change
    add_column :additional_hours, :consumed_hours, :integer, array: true, default: []
  end
end
