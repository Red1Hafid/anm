class AddTimestampsToRole < ActiveRecord::Migration[7.0]
  def change
    add_timestamps(:roles)
  end
end
