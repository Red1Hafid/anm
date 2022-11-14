class CreateFonctionalManagerExterns < ActiveRecord::Migration[7.0]
  def change
    create_table :fonctional_manager_externs do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone_number
      t.string :gender
      t.string :job_title

      t.timestamps
    end
  end
end
