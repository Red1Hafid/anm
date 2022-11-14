class CreateFonctionalManagers < ActiveRecord::Migration[7.0]
  def change
    create_table :fonctional_managers do |t|
      t.string :first_name
      t.string :last_name

      t.timestamps
    end
  end
end
