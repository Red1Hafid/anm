class AddAttributesToAutorization < ActiveRecord::Migration[7.0]
  def change
    add_column :autorizations, :department, :string
    add_column :autorizations, :function, :string
    add_column :autorizations, :recovery_method, :string
    
  end
end
