# Upload input files
class UploadsManager
    require 'csv'
  
    def self.upload_file(file_name)
      send(upload_functions_dictionnary(file_name))
    end
  
    def self.upload_functions_dictionnary(file_name)
      dictionnary = {
         #'d‚part-_action_.csv' => ,
         #'d‚part-motif.csv' => ,  
         '1.-types-de-congé.csv' => 'upload_type_de_congés',
         '2.-jours-fériés.csv' => 'upload_config_jour_fériés',
         '3.-gestionnaires-fonctionnels.csv' => 'upload_external_fonctional_managers',
         '4.-collaborateurs.csv' => 'upload_collaborators',
         '5.-congés.csv' => 'upload_furloughs',
         #'6.-heures-sup.csv' => 'upload_additional_hours',
         '7.-Autorisation.csv' => 'upload_authorizations'
      }  
  
      dictionnary[file_name]
    end
  
    # Upload BUs and Sites lists in database
    def self.upload_external_fonctional_managers
      path = "#{Rails.application.config.inputFileDirectory}/input_files/input/3.-gestionnaires-fonctionnels.csv"
  
      return unless File.exist?(path)
  
      csv_text = File.read(path)
      csv = CSV.parse(csv_text, headers: true, col_sep: ',')

      @errors = []
      successes = []

      csv.each.with_index(2) do |row, lineno|
        hash = row.to_hash
        is_fonctional = FonctionalManagerExtern.custom_finder(hash['Email'])
        if is_fonctional == false
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
              successes.push(:ligne => lineno, :message => "This line has been successfully inserted into the database")
            else
              @errors.push(:ligne => lineno, :message => fonctional.errors.full_messages)
            end
          end
        end
      end

      CSV.open("successes_3.-gestionnaires-fonctionnels" + ".csv", 'wb') do |csv|
        successes.map { |l|
            csv << [l[:ligne], l[:message], 'success']
        }
      end

      CSV.open("failures_3.-gestionnaires-fonctionnels" + ".csv", 'wb') do |csv|
          @errors.map { |l|
              csv << [l[:ligne], l[:message]]
          }
      end

      return @errors       
    end
  
    def self.upload_collaborators
      path = "#{Rails.application.config.inputFileDirectory}/input_files/input/4.-collaborateurs.csv"
  
      return unless File.exist?(path)
      csv_text = File.read(path)
      csv = CSV.parse(csv_text, headers: true, col_sep: ',')

      @errors = []
      successes = []

      csv.each.with_index(2) do |row, lineno|
        hash = row.to_hash

        is_user_exist = User.custom_finder(hash['Prénom'], hash['Nom'], hash['Email professionnel'], hash["Date d'intégration"])
        if is_user_exist == false
          if hash['Sexe'] == 'Homme'
            sexe = "1"
          else
            sexe = "0"
          end
  
          role = Role.find_by(title: hash['Role'])
  
          if hash['Résponsabilité'] != ""
            if hash['Résponsabilité'].split(/, */).first != hash['Résponsabilité'].split(/, */).last
              manager_titles = [hash['Résponsabilité'].split(/, */).first, hash['Résponsabilité'].split(/, */).last]
            else
              manager_titles = [hash['Résponsabilité'].split(/, */).first]
            end
          end
  
          @messages = []

          if hash["Statut"] == "Désactivé"
            status = "desabled"
            if hash['Raison de désactivation'] == ""
              @messages.push("Si le collaborateur est désactivé la colonne ('Raison de désactivation') est obligatoire)")
            end

            if hash['Date de désactivation'] == ""
              @messages.push("Si le collaborateur est désactivé la colonne ('Date de désactivation') est obligatoire)")
            end

            if hash['Action'] == ""
              @messages.push("Si le collaborateur est désactivé la colonne ('Action') est obligatoire)")
              stop_action_spec = hash['Action']
            else
              stop_action = StopAction.find_by(name: hash['Action'])
              if !stop_action.nil?
                  stop_action_spec = stop_action.id
              else
                @messages.push("L'action de désactivation ne se trouve pas en base de données")
              end
            end

            if hash['Motif'] == ""
              @messages.push("Si le collaborateur est désactivé la colonne ('Motif') est obligatoire)")
              ground_spec = hash['Motif']
            else
              ground = Ground.find_by(code: hash['Motif'])
              if !ground.nil?
                ground_spec = ground.id
              else
                @messages.push("Le motif de désactivation ne se trouve pas en base de données")
              end
            end
          elsif hash["Statut"] == "Actif"
            status = "actif"
          elsif hash["Statut"] == "Nouveau"
            status = "created"
          elsif hash["Statut"] == "Suspendu"
            status =  "suspended"
          end
  
          user_to_create = User.new(
              matricule: hash['ID(ou Matricule)'],
              first_name: hash['Prénom'],
              last_name: hash['Nom'],
              phone_number: hash['Téléphone'],
              home_adress: hash['Adresse'],
              gender: sexe,
              family_status: hash['Situation familiale'],
              email: hash['Email professionnel'],
              personnal_email: hash['Email personnel'],
              started_at: hash["Date d'intégration"],
              job_title: hash['Intitulé de poste'],
              manager_titles:  manager_titles, 
              role_id: role.id,
              password: "Alithya",
              password_confirmation: "Alithya",
              status: status,
              disabled_date: hash['Date de désactivation'],
              stop_action_id: stop_action_spec,
              ground_id: ground_spec,
              disable_comment: hash['Raison de désactivation']
          )

          if @messages.count == 0
            if user_to_create.valid?
              user_to_create.save
              #user_to_create.send_confirmation_instructions if hash["Statut"] == 'actif'
              successes.push(:ligne => lineno, :message => "This line has been successfully inserted into the database")
  
              user = User.find_by(matricule: hash['ID(ou Matricule)'])
              Bank.create(user_id: user.id, balance_furlough: 0.0, balance_open_additional_hour: 0, balance_open_additional_hour_off_days: 0)
            
              if hash['Résponsabilité'].include? "Gestionnaire fonctionnel"
                FonctionalManager.create(matricule: user.matricule, first_name: user.first_name, last_name: user.last_name)
              end
            else
              @errors.push(:ligne => lineno, :message => user_to_create.errors.full_messages)
            end
          else
            @errors.push(:ligne => lineno, :message => @messages)
          end
        end  
      end

      csv.each.with_index(2) do |row, lineno|
        hash = row.to_hash
        user = User.find_by(matricule: hash['ID(ou Matricule)'])
        if !user.nil?
          @messages = []
          if hash['Gestionnaire hiérarchique'] != ""
            line_manager = User.find_by(matricule: hash['Gestionnaire hiérarchique'])
            if !line_manager.nil?
              user.update(line_manager_id: line_manager.id)
            else
              @messages.push("L'association du gestionnaire hiérarchique de Cette ligne n'à pas été mise car le gestionnaire hiérarchique ne se trouve pas dans la base de donnée.")
            end
          end
          
          if  hash['Gestionnaire fonctionnel'] != ""
            fonctional_manager = FonctionalManager.find_by(matricule: hash['Gestionnaire fonctionnel'])
            if !fonctional_manager.nil?
              user.update(fonctionnal_manager_id: fonctional_manager.id)
            else
              @messages.push("L'association du gestionnaire fonctionnel de Cette ligne n'à pas été mise car le gestionnaire fonctionnel ne se trouve pas dans la base de donnée.")
            end
          end  
          
          if @messages.count > 0 
            @errors.push(:ligne => lineno, :message => @messages)
          end
        end
      end

      CSV.open("successes_4.-collaborateurs" + ".csv", 'wb') do |csv|
        successes.map { |l|
            csv << [l[:ligne], l[:message], 'success']
        }
      end

      CSV.open("failures_4.-collaborateurs" + ".csv", 'wb') do |csv|
          @errors.map { |l|
              csv << [l[:ligne], l[:message]]
          }
      end

      return @errors 
    end
  
    def self.upload_type_de_congés
      path = "#{Rails.application.config.inputFileDirectory}/input_files/input/1.-types-de-congé.csv"
  
      return unless File.exist?(path)
      csv_text = File.read(path)
      csv = CSV.parse(csv_text, headers: true, col_sep: ',')

      @errors = []
      successes = []

      csv.each.with_index(2) do |row, lineno|
        hash = row.to_hash
        is_furlough_type = FurloughType.custom_finder(hash['Nom du congé'])
        if is_furlough_type == false
          @messages = []
          if hash['Discontinuté'] == "" || hash['Discontinuté'] == "Non"
              discontinuity = false    
              if hash['Période discontinuté'] != ""
                @messages.push("le type de congé à la (Période discontinuté) définie par contre la valeur de (discontinuté) est sur Non.")
              end
          else  
              discontinuity = true
              if hash['Période discontinuté'] == ""
                @messages.push("La période de discontinuté est obligatoire si la colone (discontinuté) est sur la valeur Oui")
              end
          end

          if hash['A une durée fixe'] == "" || hash['A une durée fixe'] == "Non"
              fixed_duration = false
          else  
              fixed_duration = true
              if hash['Durée max du congé(jr)'] == ""
                  @messages.push("La duré max de type de congé est obligatoire si la colone (A une durée fixe) est sur la valeur Oui")
              end
          end

          if hash['A déclarer(48h) avant le début du congé'] == "" || hash['A déclarer(48h) avant le début du congé'] == "Non"
            informing_before = false
          else  
            informing_before = true
          end

          if hash['A compter comme jour travaillé'] == "" || hash['A compter comme jour travaillé'] == "Non"
            is_payer = false
          else  
            is_payer = true
          end

          if hash['Actif'] == "" || hash['Actif'] == "Non"
            is_actif = false
          else  
            is_actif = true
          end

          if @messages.count == 0
            furlough_type_to_create = FurloughType.new(
              name: hash['Nom du congé'],
              code: hash['Code'],
              max_duration: hash['Durée max du congé(jr)'],
              fixed_duration: fixed_duration,
              informing_before: informing_before,
              is_payer: is_payer,
              is_actif: is_actif,
              nbr_days_block: hash["Bloquer l'access au portail après"],
              discontinuity: discontinuity,
              discontinuity_period: hash['Période discontinuté']    
            )

            if furlough_type_to_create.valid?
              furlough_type_to_create.save
              successes.push(:ligne => lineno, :message => "This line has been successfully inserted into the database")
            else
              @errors.push(:ligne => lineno, :message => furlough_type_to_create.errors.full_messages)
            end
          else
            @errors.push(:ligne => lineno, :message => @messages)
          end
        end
      end

      CSV.open("successes_1.-types-de-congé" + ".csv", 'wb') do |csv|
        successes.map { |l|
            csv << [l[:ligne], l[:message], 'success']
        }
      end

      CSV.open("failures_1.-types-de-congé" + ".csv", 'wb') do |csv|
          @errors.map { |l|
              csv << [l[:ligne], l[:message]]
          }
      end

      return @errors 
    end
  
    def self.upload_config_jour_fériés
      path = "#{Rails.application.config.inputFileDirectory}/input_files/input/2.-jours-fériés.csv"
  
      return unless File.exist?(path)
      csv_text = File.read(path)
      csv = CSV.parse(csv_text, headers: true, col_sep: ',')

      @errors = []
      successes = []

      csv.each.with_index(2) do |row, lineno|
        hash = row.to_hash
        is_off = Off.custom_finder(hash['Jour férié'])
        if is_off == false

          @messages = []
          
          off_to_create = Off.new(
            code: hash['Code'],
            title: hash['Jour férié'],
            start: hash['Date de début'],
            end: hash['Date de fin'],
            description: hash['Description']
          )

        
          if off_to_create.start > off_to_create.end
              @messages.push("La date de début du jour férié ne doit pas être supérieure de la date de fin du jour férié.")
          end

          if @messages.count == 0
            if off_to_create.valid?
              off_to_create.save
              successes.push(:ligne => lineno, :message => "This line has been successfully inserted into the database")
            else
              @errors.push(:ligne => lineno, :message => off_to_create.errors.full_messages)
            end
          else
            @errors.push(:ligne => lineno, :message => @messages)
          end
        end
      end

      CSV.open("successes_2.-jours-fériés" + ".csv", 'wb') do |csv|
        successes.map { |l|
            csv << [l[:ligne], l[:message], 'success']
        }
      end

      CSV.open("failures_2.-jours-fériés" + ".csv", 'wb') do |csv|
          @errors.map { |l|
              csv << [l[:ligne], l[:message]]
          }
      end

      return @errors
    end

    def self.upload_furloughs
      path = "#{Rails.application.config.inputFileDirectory}/input_files/input/5.-congés.csv"
  
      return unless File.exist?(path)
      csv_text = File.read(path)
      csv = CSV.parse(csv_text, headers: true, col_sep: ',')

      @errors = []
      successes = []

      csv.each.with_index(2) do |row, lineno|
        hash = row.to_hash
        user = User.find_by(matricule: hash['ID (matricule)'])
        furlough_type = FurloughType.find_by(code: hash['Code congé'])

        @messages = []
        
        if furlough_type.nil?
          @messages.push("le type de congé associé à ce congé n'existe en base de donnée")  
        end

        if user.nil?
          @messages.push("le collaborateur associé à ce congé n'existe pas en base de donnée")
        else
          if hash['Statut'] == "Nouveau" || hash['Statut'] == "Soumis" || hash['Statut'] == "Refusé"
            signature_collab = "Approuvé par " + user.first_name + " " + user.last_name + " _" + " Le " + DateTime.now().strftime("%m/%d/%Y").to_s + DateTime.now().strftime(" à %I:%M%p").to_s
            signature_g_h = " "
            signature_g_f = " "
          elsif hash['Statut'] == "Approuvé" || hash['Statut'] == "Annulé" || hash['Statut'] == "En cours"
            signature_collab = "Approuvé par " + user.first_name + " " + user.last_name + " _" + " Le " + DateTime.now().strftime("%m/%d/%Y").to_s + DateTime.now().strftime(" à %I:%M%p").to_s
            if hash['Signature gestionnaire'] != ""
              g_h = User.find_by(matricule: hash['Signature gestionnaire'])
              if !g_h.nil?
                if !user.line_manager_id.nil? 
                  if user.line_manager_id == g_h.id
                    signature_g_h = "Approuvé par " + g_h.first_name + " " + g_h.last_name + " _" + " Le " + DateTime.now().strftime("%m/%d/%Y").to_s + DateTime.now().strftime(" à %I:%M%p").to_s 
                  else
                    @messages.push("Le gestionnaire hiérarchique du propriétaire de ce congé ce n'est pas le gestionnaire associé a la signature dans la colonne (Signature gestionnaire)")
                  end
                else
                  @messages.push("Le propriétaire de ce congé n'a pas un gestionnaire hiérarchique dans les information du collaborateur en base de données")
                end
              else
                @messages.push("Le gestionnaire hiérarchique associé a la signature de ce congé ne se trouve pas en base de données.")
              end
            else
              if !user.line_manager_id.nil? 
                @messages.push("Si le congé avec un statut de (Approuvé, Annulé, En cours) la colonne (Signature gestionnaire) ne doit pas être vide")
              else
                signature_g_h = " "
              end
            end

            if hash['Signature rh'] != ""
              rh = User.find_by(matricule: hash['Signature rh'])
              if !rh.nil?
                signature_g_f = "Approuvé par " + rh.first_name + " " + rh.last_name + " _" + " Le " + DateTime.now().strftime("%m/%d/%Y").to_s + DateTime.now().strftime(" à %I:%M%p").to_s 
              else
                @messages.push("Le rh associé a la signature de ce congé ne se trouve pas en base de données.")
              end   
            else
              @messages.push("Si le congé avec un statut de (Approuvé, Annulé, En cours) la colonne (Signature rh) ne doit pas être vide")
            end
          end
        end

        if hash['Statut'] != "Refusé" && hash['Statut'] == "Annulé"
          raison_cancel = ""
          raison_refus = ""
        end

        if hash['Statut'] == "Refusé"
          if hash['Raison'] == "" 
            @messages.push("Si le congé est avec le statut (Refusé) la raison de refus est obligatoire.")
          else
            raison_refus = hash['Raison']
            raison_cancel = ""
          end

          if hash['Date du refus'] == ""
            @messages.push("Si le congé est avec le statut (Refusé) la la date de refus est obligatoire.")
          else
            if hash['Date du refus'].to_date > Date.today
              @messages.push("La date de refus ne doit pas être supérieure que la date d'aujourd hui")
            end
          end
        end

        if hash['Statut'] == "Annulé"
          if hash['Raison'] == ""
            @messages.push("Si le congé est avec le statut (Annulé) la raison d'annulation est obligatoire.")
          else
            raison_cancel = hash['Raison']
            raison_refus = ""
          end

          if hash["Date d'annulation"] == ""
            @messages.push("Si le congé est avec le statut (Annulé) la date d'annulation est obligatoire.")
          else
            if hash["Date d'annulation"].to_date > Date.today
              @messages.push("La date de refus ne doit pas être supérieure que la date d'aujourd hui")
            end
          end
        end

        if !['En cours', 'Nouveau', 'Approuvé', 'Refusé', 'Soumis', 'Annulé'].include? hash['Statut']
          @messages.push("Le statut du congé n'est pas correcte")
        end

        if hash['Date de début'].to_date > hash['Date de fin'].to_date
          @messages.push("La date de début de congé ne doit pas être supérieure que la date de fin.")
        end
        
        if @messages.count == 0
          is_furlough = Furlough.custom_finder(hash['Date de début'], hash['Heure de début'], hash['Date de fin'], hash['Heure de fin'], user.id, furlough_type.id, hash['Statut'])
          if is_furlough == false
            furlough = Furlough.new(
              reference_furlough: hash['Référence du congé'],
              furlough_type_id: furlough_type.id,
              user_id: user.id,
              start: hash['Date de début'],
              hour_start: hash['Heure de début'],
              end: hash['Date de fin'],
              hour_end: hash['Heure de fin'],
              status: hash['Statut'],
              refus_date: hash['Date du refus'],
              refuse_comment: raison_refus,
              cancel_date: hash["Date d'annulation"],
              cancel_comment: raison_cancel,
              signature_collab: signature_collab,
              signature_g_h: signature_g_h,
              signature_g_f: signature_g_f
            )

            if furlough.valid?
              furlough.save
              successes.push(:ligne => lineno, :message => "This line has been successfully inserted into the database")
            else
              @errors.push(:ligne => lineno, :message => furlough.errors.full_messages)
            end
          end
        else
          @errors.push(:ligne => lineno, :message => @messages)
        end
      end

      CSV.open("successes_5.-congés" + ".csv", 'wb') do |csv|
        successes.map { |l|
            csv << [l[:ligne], l[:message], 'success']
        }
      end

      CSV.open("failures_5.-congés" + ".csv", 'wb') do |csv|
          @errors.map { |l|
              csv << [l[:ligne], l[:message]]
          }
      end

      return @errors
    end

    def self.upload_additional_hours
      path = "#{Rails.application.config.inputFileDirectory}/input_files/input/6.-heures-sup.csv"
  
      return unless File.exist?(path)
      csv_text = File.read(path)
      csv = CSV.parse(csv_text, headers: true, col_sep: ',')

      @errors = []
      successes = []

      csv.each.with_index(2) do |row, lineno|
        hash = row.to_hash
        user = User.find_by(matricule: hash['ID (matricule)'])
        additional_hours_type = AdditionalHourType.find_by(code: hash['Code HSup'])

        @messages = []
        
        if additional_hours_type.nil?
          @messages.push("le type d'heures sup associé à cette période n'existe pasen base de donnée")  
        end

        if user.nil?
          @messages.push("le collaborateur associé à à cette période n'existe pas en base de donnée")
        else
          is_additional_hour = AdditionalHour.custom_finder(hash['Période'], hash['Code HSup'], user.id)

          if is_additional_hour == true
            @messages.push("cette période a été déja inséré en base de données")
          end
        end

        period = hash['Période']
        start_period = period.split(/ - */).first.to_date
        end_period = period.split(/ - */).last.to_date

        if start_period > end_period
          @messages.push("La date de début du période ne doit pas être supérieure que la date de fin.")
        end

        period_days = (start_period.to_date..end_period.to_date).to_a.select {|k| [0,1,2,3,4,5,6].include?(k.wday)}
        if period_days.count > 7 || period_days.count < 7
          @messages.push("La période doit contenir 7 jours ni moins ni plus! (du lundi au dimanche)")
        end

        #case hash['Statut']
       # when 'Enregistré'
          #status = 1
        #when 'Validé'
         # status = 2
       # when "Expiré"
          #status = 3
        #end
        consumed_hours = []

        if hash['Code HSup'] == "HSJO"
          if hash['Consommé (hr)'] != ""
            @messages.push("la colonne Consommé (hr) doit être vide si le type d'heures sup est HSJO")
          else
            consumed_hours.push(0)
          end
        else
          consumed_hours = []
          if hash['Consommé (hr)'] != ""
            consumed_hours.push(hash['Consommé (hr)'].to_i)
          else
            consumed_hours.push(0)
          end 
        end

        if hash['Code HSup'] == "HSJO"
          if hash['Reste(hr)'] != ""
            @messages.push("la colonne Reste(hr) doit être vide si le type d'heures sup est HSJO")
          end
        end
       
        
        if @messages.count == 0
          additional_hour = AdditionalHour.new(
            user_id: user.id,
            additional_hour_type_id: additional_hours_type.id,
            period: hash['Période'],
            status: hash['Statut'].to_i,
            consumed_hours: consumed_hours,
            stay_hours: hash['Reste(hr)'].to_i,
            monday_quantity: hash['Volume Lundi'].to_i,
            tuesday_quantity: hash['Volume Mardi'].to_i,
            wednesday_quantity: hash['Volume Mercredi'].to_i,
            thursday_quantity: hash['Volume Jeudi'].to_i,
            friday_quantity: hash['Volume Vendredi'].to_i,
            saturday_quantity: hash['Volume Samedi'].to_i,
            sunday_quantity: hash['Volume Dimanche'].to_i,
            total_additional_hour_in_week: hash['Total'].to_i
          )

          if additional_hour.valid?
            additional_hour.save

            bank = Bank.find_by(user_id: user.id)
            if hash['Code HSup'] == "HSJFT"
              case hash['Statut']
              when "1"
                total_additional_hour = bank.balance_open_additional_hour_off_days + additional_hour.stay_hours
                bank.update(balance_open_additional_hour_off_days: total_additional_hour)  
              when "2"
                total_additional_hour = bank.balance_open_additional_hour_off_days + additional_hour.stay_hours
                bank.update(balance_open_additional_hour_off_days: total_additional_hour)
              end
              bank.save
            else
              case hash['Statut']
              when "1"
                total_additional_hour = bank.balance_open_additional_hour + hash['Total'].to_i
                bank.update(balance_open_additional_hour: total_additional_hour)  
              when "2"
                balance_furlough_after_add_total_additional_hour = bank.balance_furlough + (hash['Total'].to_f / 8)
                bank.update(balance_furlough: balance_furlough_after_add_total_additional_hour)
              end
              bank.save
            end
            successes.push(:ligne => lineno, :message => "This line has been successfully inserted into the database")
          else
            @errors.push(:ligne => lineno, :message => additional_hour.errors.full_messages)
          end
          
        else
          @errors.push(:ligne => lineno, :message => @messages)
        end
      end

      CSV.open("successes_6.-heures-sup" + ".csv", 'wb') do |csv|
        successes.map { |l|
            csv << [l[:ligne], l[:message], 'success']
        }
      end

      CSV.open("failures_6.-heures-sup" + ".csv", 'wb') do |csv|
          @errors.map { |l|
              csv << [l[:ligne], l[:message]]
          }
      end

      return @errors
    end

    def self.upload_authorizations
      path = "#{Rails.application.config.inputFileDirectory}/input_files/input/7.-Autorisation.csv"
  
      return unless File.exist?(path)
      csv_text = File.read(path)
      csv = CSV.parse(csv_text, headers: true, col_sep: ',')

      @errors = []
      successes = []

      csv.each.with_index(2) do |row, lineno|
        hash = row.to_hash
        user = User.find_by(matricule: hash['ID (matricule)'])

        @messages = []

        date = hash['Date de sortie']
        start_hour = hash['Heure de sortie']
        end_hour = hash['Heure de reprise']

        if start_hour == end_hour
          @messages.push("L'autorisation n'est pas valide - duré égale 0!")
        elsif start_hour.split(/: */).first.to_i > end_hour.split(/: */).first.to_i
          @messages.push("L'autorisation n'est pas valide - heure de sortie > heure de reprise!")
        end

        authorization__hour_duration = Autorization.get_hour_authorization_duration(date, start_hour, end_hour)

        if authorization__hour_duration >= 3
          stay_hours = authorization__hour_duration
          if hash['Type de récupération'] == ""
            @messages.push("Si l'autorisation dépasse ou égale 3 heures la colonne Type de récupération ne doit pas étre vide")
          end
        else
          stay_hours = 0.0
        end

        if user.nil?
          @messages.push("le collaborateur associé à à cette période n'existe pas en base de donnée")
        else
          is_authorization = Autorization.custom_finder(date, start_hour, end_hour, user.id)

          if is_authorization == true
            @messages.push("cette autorisation a été déja inséré en base de données")
          end
        end

        case hash['Statut']
        when "Nouveau"
          status = 1
        when "En cours"
          status = 2
        when "Soumis"
          status = 3
        when "Validé"
          status = 4
        else
          status = 5
        end
               
        if @messages.count == 0
          authorization = Autorization.new(
            user_id: user.id,
            date: date,
            start_hour: start_hour,
            end_hour: end_hour,
            stay_hour: stay_hours,
            status: status,
            comment: hash['Motif'],
            department: hash['Département'],
            function: hash['Fonction'],
            recovery_method: hash['Type de récupération']
          )

          if authorization.valid?
            authorization.save
            successes.push(:ligne => lineno, :message => "This line has been successfully inserted into the database")
          else
            @errors.push(:ligne => lineno, :message => authorization.errors.full_messages)
          end
          
        else
          @errors.push(:ligne => lineno, :message => @messages)
        end
      end

      CSV.open("successes_7.-Autorisation" + ".csv", 'wb') do |csv|
        successes.map { |l|
            csv << [l[:ligne], l[:message], 'success']
        }
      end

      CSV.open("failures_7.-Autorisation" + ".csv", 'wb') do |csv|
          @errors.map { |l|
              csv << [l[:ligne], l[:message]]
          }
      end

      return @errors
    end
end
  