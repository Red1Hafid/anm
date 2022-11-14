class AddAttributesHoursToFurlough < ActiveRecord::Migration[7.0]
  def change
    add_column :furloughs, :hour_start, :string
    add_column :furloughs, :hour_end, :string
  end
end
