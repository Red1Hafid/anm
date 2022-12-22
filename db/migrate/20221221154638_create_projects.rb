class CreateProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.boolean :is_active
      t.string :description
      t.float :unit_affaire
      t.string :client

      t.timestamps
    end
  end
end
