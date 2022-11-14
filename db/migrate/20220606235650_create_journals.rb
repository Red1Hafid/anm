class CreateJournals < ActiveRecord::Migration[7.0]
  def change
    create_table :journals do |t|
      t.text :content
      t.string :status
      t.string :the_model
      t.bigint :the_model_id
      t.boolean :viewed, default: 0
      t.references :user, null: true, foreign_key: true
    
      t.timestamps
    end
  end
end
