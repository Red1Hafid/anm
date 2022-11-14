class AddCodeToOffs < ActiveRecord::Migration[7.0]
  def change
    add_column :offs, :code, :string, :null => false
  end
end
