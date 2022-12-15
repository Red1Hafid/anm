class AddAttributesToCompletAttestationToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :gross_salary, :float
    add_column :users, :cnss, :string
    add_column :users, :cin, :string
    add_column :users, :date_birth, :date

  end
end
