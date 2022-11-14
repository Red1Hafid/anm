class AddReferenceToFurloughs < ActiveRecord::Migration[7.0]
  def change
    add_reference :furloughs, :furlough_type, null: false, foreign_key: true
  end
end
