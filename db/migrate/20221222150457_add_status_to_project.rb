class AddStatusToProject < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :status, :integer, default: 1
    add_column :projects, :project_type, :string, default: "Project Facturable"
    rename_column :projects, :created_at, :enabled_date
    rename_column :projects, :updated_at, :disabled_at
  end
end
