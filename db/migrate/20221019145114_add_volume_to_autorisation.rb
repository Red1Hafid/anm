class AddVolumeToAutorisation < ActiveRecord::Migration[7.0]
  def change
    add_column :autorizations, :volume, :float
  end
end
