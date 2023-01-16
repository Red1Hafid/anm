class CreateUserConfs < ActiveRecord::Migration[7.0]
  def change
    create_table :user_confs do |t|
      t.string :ref
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
