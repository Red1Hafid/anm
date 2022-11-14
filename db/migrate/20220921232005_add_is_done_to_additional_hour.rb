class AddIsDoneToAdditionalHour < ActiveRecord::Migration[7.0]
  def change
    add_column :additional_hours, :is_done, :boolean, default: false
  end
end
