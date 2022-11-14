class AddStopParamsToFurlough < ActiveRecord::Migration[7.0]
  def change
    add_column :furloughs, :stop_date, :datetime
    add_column :furloughs, :stop_comment, :text
  end
end
