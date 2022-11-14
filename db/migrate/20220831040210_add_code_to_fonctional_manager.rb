class AddCodeToFonctionalManager < ActiveRecord::Migration[7.0]
  def change
    add_column :fonctional_managers, :matricule, :string, :null => false
  end
end
