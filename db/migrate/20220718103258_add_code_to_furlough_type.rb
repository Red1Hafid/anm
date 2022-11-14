class AddCodeToFurloughType < ActiveRecord::Migration[7.0]
  def change
    add_column :furlough_types, :code, :string
  end
end
