class AddAtributesToCost < ActiveRecord::Migration[7.0]
  def change
    add_column :costs, :percentage, :string
    add_column :costs, :is_active, :boolean
    add_column :costs, :enabled_date, :date
    add_column :costs, :disabled_date, :date
    add_column :costs, :max_value, :float
    add_column :costs, :status, :integer, default: 1
  end
end
