class AddAttributesToFurloughs < ActiveRecord::Migration[7.0]
  def change
    add_column :furloughs, :cancel_comment, :text
    add_column :furloughs, :refuse_comment, :text
  end
end
