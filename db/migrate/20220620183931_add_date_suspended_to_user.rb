class AddDateSuspendedToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :suspend_date, :datetime
  end
end
