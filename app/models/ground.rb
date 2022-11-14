class Ground < ApplicationRecord
    validates :description, presence: true, format: {with: /[a-zA-Z]/}
    validates :description, uniqueness: true
    validates :code, presence: true
    validates :code, uniqueness: true

    belongs_to :stop_action

    def self.import(file)
        @errors = []
        successes = []

        CSV.foreach(file.path, headers: true) do |row|
            hash = row.to_hash
            stop_action = StopAction.find_by(code: hash['Code Action'])

            if !stop_action.nil?
                stop_action_id = stop_action.id

                ground_to_create = Ground.new(
                    code: hash['Code Motif'],
                    description: hash['Motifs'],
                    stop_action_id: stop_action_id
                )

                if ground_to_create.valid?
                    ground_to_create.save
                    successes.push(:ligne => hash['Ligne'], :message => "Cette ligne à été bien inséré en base de données")
                else
                    @errors.push(:ligne => hash['Ligne'], :message => ground_to_create.errors.objects.each { |e| e.full_message })
                end
            else
                @errors.push(:ligne => hash['Ligne'], :message => "L'action associé a ce motif ne se trouve pas en base de données")
            end
        end

        CSV.open("successes_motif_de_départ" + ".csv", 'wb') do |csv|
            successes.map { |l|
                csv << [l[:ligne], l[:message], 'success']
            }
        end

        CSV.open("failures_motif_de_départ" + ".csv", 'wb') do |csv|
            @errors.map { |l|
                csv << [l[:ligne], l[:message]]
            }
        end
    end
end
