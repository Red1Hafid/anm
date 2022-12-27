class AddRefrencesToAffection < ActiveRecord::Migration[7.0]
  def change
    add_reference :affectations, :user, index: true
    add_reference :affectations, :project, index: true
    add_column :affectations, :type_affectation, :string
    add_column :affectations, :comments, :text
    add_column :affectations, :date_affectation, :date
    add_column :affectations, :date_disacffectation, :date
  end
end
