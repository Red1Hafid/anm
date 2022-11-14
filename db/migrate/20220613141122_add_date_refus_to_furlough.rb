class AddDateRefusToFurlough < ActiveRecord::Migration[7.0]
  def change
    add_column :furloughs, :refus_date, :datetime
  end
end
