class AddStatusToCost < ActiveRecord::Migration[7.0]
  def change
    add_column :costs, :status, :integer, default: 1
  end
end
