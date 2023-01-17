class Intern < ApplicationRecord
    
    serialize :technical_skills, Array
    serialize :language_skills, Array

    validates :matricule, presence: true
    validates :matricule, uniqueness: true

    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :email, uniqueness: true

    validates :gsm, presence: true
    validates :gsm, uniqueness: true

    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :technical_skills, presence: true
    validates :language_skills, presence: true
    validates :college_year, presence: true

    LANGUAGES = ["Français", "Anglais"]
    SKILLS = ["Ruby On Rails", "Blender"]
end
