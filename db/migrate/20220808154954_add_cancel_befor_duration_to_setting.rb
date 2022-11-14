class AddCancelBeforDurationToSetting < ActiveRecord::Migration[7.0]
  def change
    add_column :settings, :cancel_after_duration, :integer
  end
end
