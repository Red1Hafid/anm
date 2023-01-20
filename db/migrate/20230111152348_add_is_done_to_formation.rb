class AddIsDoneToFormation < ActiveRecord::Migration[7.0]
  def change
    add_column :formations, :is_done, :boolean
  end
end
