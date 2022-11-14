class AddMatriculeToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :matricule, :string, :null => false
  end
end
