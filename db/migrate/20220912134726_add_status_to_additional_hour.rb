class AddStatusToAdditionalHour < ActiveRecord::Migration[7.0]
  def change
    add_column :additional_hours, :status, :integer, default: 1
  end
end
