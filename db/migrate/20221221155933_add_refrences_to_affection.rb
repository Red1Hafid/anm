class AddRefrencesToAffection < ActiveRecord::Migration[7.0]
  def change
    add_reference :affectations, :user, index: true
    add_reference :affectations, :project, index: true
    add_column :affectations, :type_affectation, :string
    rename_column :affectations, :updated_at, :date_affectation
    rename_column :affectations, :created_at, :date_Désaffection
  end
end
