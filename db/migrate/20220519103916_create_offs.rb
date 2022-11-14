class CreateOffs < ActiveRecord::Migration[7.0]
  def change
    create_table :offs do |t|
      t.string :title
      t.text :description
      t.datetime :start
      t.datetime :end
      t.string :color
    end
  end
end
