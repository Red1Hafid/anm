class CreateFurloughTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :furlough_types do |t|
      t.string :name
      t.integer :max_duration
      t.boolean :fixed_duration
      t.boolean :informing_before
    end
  end
end
