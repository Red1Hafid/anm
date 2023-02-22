class FonctionalManagerExtern < ApplicationRecord
  validates :first_name, presence: true, format: {with: /[a-zA-Z]/}
  validates :id_external_manager, presence: true
  validates :id_external_manager, uniqueness: true
  validates :last_name, presence: true, format: {with: /[a-zA-Z]/}
  #validates :job_title, presence: true, format: {with: /[a-zA-Z]/}
  validates :phone_number, presence: true, numericality: { only_integer: true }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: true

  acts_as_tenant :company

  def full_name_fonctional_manager_extern
    "#{first_name} #{last_name}"
  end

  def full_name_user
    "#{first_name} #{last_name}"
  end

  def self.import(file)
    @errors = []
    successes = []

    CSV.foreach(file.path, headers: true) do |row|
      hash = row.to_hash
        FonctionalManagerExtern.transaction(requires_new: true) do 
          fonctional = FonctionalManagerExtern.new(
            id_external_manager: hash['Id'], 
            first_name: hash['Nom'], 
            last_name: hash['Prénom'], 
            email: hash['Email'], 
            job_title: hash["Poste"], 
            phone_number: hash['Telephone']
          )

          if fonctional.valid?
            fonctional.save
            FonctionalManager.find_or_create_by(matricule: hash['Id'], first_name: hash['Nom'], last_name: hash['Prénom'])
            successes.push(:ligne => hash['Ligne'], :message => "Cette ligne à été bien inséré en base de données")
          else
            @errors.push(:ligne => hash['Ligne'], :message => fonctional.errors.objects.each { |e| e.full_message })
          end
        end
    end

    CSV.open("successes_Gestionnaire-fonctionnel-externe" + ".csv", 'wb') do |csv|
      successes.map { |l|
          csv << [l[:ligne], l[:message], 'success']
      }
    end

    CSV.open("failures_Gestionnaire-fonctionnel-externe" + ".csv", 'wb') do |csv|
      @errors.map { |l|
          csv << [l[:ligne], l[:message]]
      }
    end
  end

  def self.custom_finder(email)
    fonctional = FonctionalManagerExtern.find_by(email: email)
    if fonctional.present?
     return true
    else
      return false
    end
  end
end