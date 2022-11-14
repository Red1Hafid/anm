class StopAction < ApplicationRecord
    validates :code, presence: true
    validates :code, uniqueness: true
    validates :name, presence: true, format: {with: /[a-zA-Z]/}
    validates :name, uniqueness: true

    has_many :grounds

    def self.import(file)
        @errors = []
        successes = []

        CSV.foreach(file.path, headers: true) do |row|
            hash = row.to_hash
            stop_action_to_create = StopAction.new(
                code: hash['Code Action'],
                name: hash['Action']  	
            )

            if stop_action_to_create.valid?
                stop_action_to_create.save
                successes.push(:ligne => hash['Ligne'], :message => "Cette ligne à été bien inséré en base de données")
            else
                @errors.push(:ligne => hash['Ligne'], :message => stop_action_to_create.errors.objects.each { |e| e.full_message })
            end
        end

        CSV.open("successes_actions_de_départ" + ".csv", 'wb') do |csv|
            successes.map { |l|
                csv << [l[:ligne], l[:message], 'success']
            }
        end
    
        CSV.open("failures_actions_de_départ" + ".csv", 'wb') do |csv|
            @errors.map { |l|
                csv << [l[:ligne], l[:message]]
            }
        end
    end
end
