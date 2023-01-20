class AddManagerToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :manager_titles, :string, array: true, default: []
  end
end
