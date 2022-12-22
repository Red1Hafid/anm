class CreateAffectations < ActiveRecord::Migration[7.0]
  def change
    create_table :affectations do |t|

      t.timestamps
    end
  end
end
