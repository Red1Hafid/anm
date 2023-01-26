class AddHourDurationToAuthorization < ActiveRecord::Migration[7.0]
  def change
    add_column :autorizations, :time_taken, :integer
  end
end
