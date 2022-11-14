class AddCodeToStopAction < ActiveRecord::Migration[7.0]
  def change
    add_column :stop_actions, :code, :string, :null => false
  end
end
