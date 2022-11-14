class CreateAdditionalHours < ActiveRecord::Migration[7.0]
  def change
    create_table :additional_hours do |t|
      t.string :period
      t.integer :total_additional_hour_in_week
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
