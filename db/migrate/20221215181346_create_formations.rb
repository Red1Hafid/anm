class CreateFormations < ActiveRecord::Migration[7.0]
  def change
    create_table :formations do |t|
      t.float :total_hour
      t.date :start_date
      t.date :end_date
      t.string :description
      t.references :user, null: false, foreign_key: true
      t.references :formation_type, null: false, foreign_key: true

      t.timestamps
    end
  end
end
