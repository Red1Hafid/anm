class AddParentAttributesToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :line_manager_id, :integer, null: true
    add_column :users, :fonctionnal_manager_id, :integer, null: true
  end
end
