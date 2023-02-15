class AddAttributesToAuthorization < ActiveRecord::Migration[7.0]
  def change
    add_column :autorizations, :demand_date, :datetime
    add_column :autorizations, :submit_date, :datetime
    add_column :autorizations, :validate_date, :datetime
    add_column :autorizations, :refus_date, :datetime
    add_column :autorizations, :refus_motif, :text
  end
end
