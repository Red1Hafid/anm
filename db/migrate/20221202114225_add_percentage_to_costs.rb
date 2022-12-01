class AddPercentageToCosts < ActiveRecord::Migration[7.0]
  def change
    add_column :costs, :percentage, :integer
  end
end
