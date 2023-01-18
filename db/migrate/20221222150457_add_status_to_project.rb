class AddStatusToProject < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :status, :integer, default: 1
    add_column :projects, :project_type, :string, default: "Project Facturable"
    add_column :projects, :reference, :string
    add_column :projects, :enabled_date, :date
    add_column :projects, :disabled_at, :date
  end
end
