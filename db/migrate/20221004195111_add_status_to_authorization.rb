class AddStatusToAuthorization < ActiveRecord::Migration[7.0]
  def change
    add_column :autorizations, :status, :integer, default: 1
  end
end
