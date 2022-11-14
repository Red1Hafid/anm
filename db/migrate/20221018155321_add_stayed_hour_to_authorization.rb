class AddStayedHourToAuthorization < ActiveRecord::Migration[7.0]
  def change
    add_column :autorizations, :stay_hour, :integer
  end
end
