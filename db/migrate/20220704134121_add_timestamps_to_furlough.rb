class AddTimestampsToFurlough < ActiveRecord::Migration[7.0]
  def change
    add_timestamps :furloughs
  end
end
