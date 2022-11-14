class AddRegularIdToFurlough < ActiveRecord::Migration[7.0]
  def change
   add_column :furloughs, :furlough_regular_id, :integer
  end
end
