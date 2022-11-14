class AddContraintDurationToSetting < ActiveRecord::Migration[7.0]
  def change
    add_column :settings, :informin_before_duration, :integer
  end
end
