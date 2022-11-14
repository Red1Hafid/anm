class AddConfirmationStartedAtToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :is_started_at_confirmed, :boolean, :null => false, :default => false
  end
end
