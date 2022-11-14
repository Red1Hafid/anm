class AddDateCancelToFurloughs < ActiveRecord::Migration[7.0]
  def change
    add_column :furloughs, :cancel_date, :date
  end
end
