class FurloughType < ApplicationRecord
    validates :code, uniqueness: true
    validates :code, presence: true
    validates :name, presence: true

    acts_as_tenant :company
    has_many :furloughs

    def self.import(file)
        @errors = []
        successes = []

        CSV.foreach(file.path, headers: true) do |row|
            hash = row.to_hash
            status_discontinuity = "success"
            if hash['Discontinuté'] == "" || hash['Discontinuté'] == "Non"
                discontinuity = false
            else  
                discontinuity = true
                if hash['Période discontinuté'] == ""
                    status_discontinuity = "failed"
                end
            end

            status_fixed_duration = "success"
            if hash['A une durée fixe'] == "" || hash['A une durée fixe'] == "Non"
                fixed_duration = false
            else  
                fixed_duration = true
                if hash['Durée max du congé(jr)'] == ""
                    status_fixed_duration = "failed"
                end
            end

            furlough_type_to_create = FurloughType.new(
                        name: hash['Nom du congé'],
                        code: hash['Code'],
                        max_duration: hash['Durée max du congé(jr)'],
                        fixed_duration: hash['A une durée fixe'],
                        informing_before: hash['A déclarer(48h) avant le début du congé'],
                        is_payer: hash['A compter comme jour travaillé'],
                        is_actif: hash['Actif'],
                        nbr_days_block: hash["Bloquer l'access au portail après"],
                        discontinuity: discontinuity,
                        discontinuity_period: hash['Période discontinuté']    
                    )

            is_furlough_type = custom_finder(hash['Nom du congé'])

            if is_furlough_type == false
                if furlough_type_to_create.valid?
                    if (status_discontinuity == "success" && status_fixed_duration == "success")
                        furlough_type_to_create.save
                        successes.push(:ligne => hash['Ligne'], :message => "Cette ligne à été bien inséré en base de données")
                    else 
                        @errors.push(:ligne => hash['Ligne'], :message => "La période de discontinuté est obligatoire si la colone (discontinuté) est sur la valeur Oui") if (status_fixed_duration == "success" && status_discontinuity == "failed")
                        @errors.push(:ligne => hash['Ligne'], :message => "La duré max de type de congé est obligatoire si la colone (A une durée fixe) est sur la valeur Oui") if (status_fixed_duration == "failed" && status_discontinuity == "success")
                        @errors.push(:ligne => hash['Ligne'], :message => "La période de discontinuté est obligatoire si la colone discontinuté est sur la valeur Oui et La duré max de type de congé est obligatoire si la colone (A une durée fixe) est sur la valeur Oui") if (status_fixed_duration == "failed" && status_discontinuity == "failed")
                    end     
                else
                    @errors.push(:ligne => hash['Ligne'], :message => furlough_type_to_create.errors.objects.each { |e| e.full_message })
                end
            else
                @errors.push(:ligne => hash['Ligne'], :message => "This line exists in the database")
            end    
        end

        CSV.open("successes_type-de-congés" + ".csv", 'wb') do |csv|
            successes.map { |l|
                csv << [l[:ligne], l[:message], 'success']
            }
        end

        CSV.open("failures_type-de-congés" + ".csv", 'wb') do |csv|
            @errors.map { |l|
                csv << [l[:ligne], l[:message]]
            }
        end
    end

    def self.custom_finder(name)
        furlough_type = FurloughType.find_by(name: name)
        if furlough_type.present?
         return true
        else
          return false
        end
    end
end