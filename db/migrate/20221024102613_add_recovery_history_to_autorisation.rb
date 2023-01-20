class AddRecoveryHistoryToAutorisation < ActiveRecord::Migration[7.0]
  def change
    add_column :autorizations, :history, :string, array: true, default: []
    add_column :autorizations, :history_date, :date
  end
end
