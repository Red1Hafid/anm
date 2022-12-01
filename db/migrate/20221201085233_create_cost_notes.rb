class CreateCostNotes < ActiveRecord::Migration[7.0]
  def change
    create_table :cost_notes do |t|
      t.integer :cost_id
      t.integer :note_id
      t.timestamps
    end
  end
end
