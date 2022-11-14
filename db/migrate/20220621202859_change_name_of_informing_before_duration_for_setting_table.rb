class ChangeNameOfInformingBeforeDurationForSettingTable < ActiveRecord::Migration[7.0]
  def change
    rename_column :settings, :informin_before_duration, :informing_before_duration
  end
end
