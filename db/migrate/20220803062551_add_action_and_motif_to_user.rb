class AddActionAndMotifToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :stop_action_id, :string
    add_column :users, :ground_id, :string
  end
end
