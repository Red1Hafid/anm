class CreateBanks < ActiveRecord::Migration[7.0]
  def change
    create_table :banks do |t|
      t.integer :user_id
      t.float :balance_furlough

      t.timestamps
    end
  end
end
