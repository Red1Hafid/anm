class AddParentFurloughToFurlough < ActiveRecord::Migration[7.0]
  def change
    add_column :furloughs, :parent_id, :integer
  end
end
