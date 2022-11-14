class AddNaissanceChildCollabToFurlough < ActiveRecord::Migration[7.0]
  def change
    add_column :furloughs, :child_date, :date
  end
end
