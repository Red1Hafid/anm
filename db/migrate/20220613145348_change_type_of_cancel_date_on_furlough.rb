class ChangeTypeOfCancelDateOnFurlough < ActiveRecord::Migration[7.0]
  def change
    change_column :furloughs, :cancel_date, :datetime
  end
end
