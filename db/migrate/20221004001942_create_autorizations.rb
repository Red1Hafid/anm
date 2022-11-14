class CreateAutorizations < ActiveRecord::Migration[7.0]
  def change
    create_table :autorizations do |t|
      t.date :date
      t.string :start_hour
      t.string :end_hour
      t.text :comment
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
