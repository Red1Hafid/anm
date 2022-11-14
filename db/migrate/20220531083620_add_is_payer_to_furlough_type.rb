class AddIsPayerToFurloughType < ActiveRecord::Migration[7.0]
  def change
    add_column :furlough_types, :is_payer, :boolean
  end
end
