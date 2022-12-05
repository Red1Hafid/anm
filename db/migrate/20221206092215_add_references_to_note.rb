class AddReferencesToNote < ActiveRecord::Migration[7.0]
  def change
    add_reference :notes, :user, index: true
    add_reference :notes, :cost, index: true
    add_column :notes, :total, :float
  end
end
