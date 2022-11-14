class CreateAdditionalHourTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :additional_hour_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
