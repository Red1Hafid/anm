class CreateFurloughs < ActiveRecord::Migration[7.0]
  def change
    create_table :furloughs do |t|
      t.string :title
      t.text :description
      t.datetime :start
      t.datetime :end
      t.string :color
      t.string :status
      t.references :user, null: false, foreign_key: true
    end
  end
end
