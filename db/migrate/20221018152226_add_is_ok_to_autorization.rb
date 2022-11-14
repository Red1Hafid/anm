class AddIsOkToAutorization < ActiveRecord::Migration[7.0]
  def change
    add_column :autorizations, :is_ok, :boolean, default: false
  end
end
