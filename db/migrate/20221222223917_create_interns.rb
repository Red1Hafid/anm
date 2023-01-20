class CreateInterns < ActiveRecord::Migration[7.0]
  def change
    create_table :interns do |t|
      t.string :matricule
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :college_year
      t.string :gsm
      t.boolean :past_interview
      t.boolean :is_passable
      t.text :opinion_interview
      t.text :opinion_internship
      t.string :desired_internship
      t.string :potential_internship
      t.string :technical_skills
      t.string :language_skills

      t.timestamps
     
    end

    
    
    
  end
end
