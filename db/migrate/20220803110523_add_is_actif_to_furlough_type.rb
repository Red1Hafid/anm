class AddIsActifToFurloughType < ActiveRecord::Migration[7.0]
  def change
    add_column :furlough_types, :is_actif, :boolean, :null => false, :default => true
    add_column :furlough_types, :nbr_days_block, :integer
    add_column :furlough_types, :discontinuity, :boolean, :null => false, :default => false
    add_column :furlough_types, :discontinuity_period, :integer
  end
end
