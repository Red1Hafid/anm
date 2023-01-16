class CreateTemplateAttestations < ActiveRecord::Migration[7.0]
  def change
    create_table :template_attestations do |t|
      t.string :name
      t.string :code
      t.text :paragraphe_1
      t.text :paragraphe_2
      t.text :paragraphe_3
      t.text :footer

      t.timestamps
    end
  end
end
