class AddCodeToAdditionalHourType < ActiveRecord::Migration[7.0]
  def change
    add_column :additional_hour_types, :code, :string
  end
end
