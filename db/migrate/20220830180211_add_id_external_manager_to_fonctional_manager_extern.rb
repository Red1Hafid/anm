class AddIdExternalManagerToFonctionalManagerExtern < ActiveRecord::Migration[7.0]
  def change
    add_column :fonctional_manager_externs, :id_external_manager, :string, :null => false
  end
end
