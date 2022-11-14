class AddCodeMotifToGround < ActiveRecord::Migration[7.0]
  def change
    add_column :grounds, :code, :string, :null => false
  end
end
