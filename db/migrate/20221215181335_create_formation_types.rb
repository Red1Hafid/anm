class CreateFormationTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :formation_types do |t|
      t.string :description
      t.string :code

      t.timestamps
    end
  end
end
