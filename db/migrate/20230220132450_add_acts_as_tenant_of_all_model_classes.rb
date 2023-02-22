class AddActsAsTenantOfAllModelClasses < ActiveRecord::Migration[7.0]
  def change
    models = []
    ActiveRecord::Base.connection.tables.map do |model|
      models.push(model)
    end
    models.delete_if {|x| ["roles", "additional_hour_types", "settings", "ar_internal_metadata", "schema_migrations"].include? x }

    models.each do |m|
      add_reference :"#{m}", :company, foreign_key: true
    end 
  end
end
