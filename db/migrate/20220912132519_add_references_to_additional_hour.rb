class AddReferencesToAdditionalHour < ActiveRecord::Migration[7.0]
  def change
    add_reference :additional_hours, :additional_hour_type, null: false, foreign_key: true
  end
end
