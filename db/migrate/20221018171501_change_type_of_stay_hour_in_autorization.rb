class ChangeTypeOfStayHourInAutorization < ActiveRecord::Migration[7.0]
  def change
    change_column :autorizations, :stay_hour, :float
  end
end
