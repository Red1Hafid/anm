class AutorizationPdf < Prawn::Document

    def initialize(authorization, authorization_duration)
        super()

        move_down(40)

        image "#{Rails.root}/app/assets/images/logo.png", :at => [6, 700], :scale => 0.45 

        text "Alithya Numérique Maroc", :align => :right
        move_down(30)
        text "Fait le #{Date.current}", :align => :right

        move_down(30)

        text "Nom : #{authorization.user.last_name}" 

        text "Prénom : #{authorization.user.first_name}"

        move_down(60)

        text "- Date de sortie: #{authorization.date.strftime('%d/%m/%Y')}"

        move_down(30)

        text "- Heure de sortie: #{authorization.start_hour}"

        move_down(30)

        text "- Heure de fin d'autorisation: #{authorization.end_hour}"

        move_down(30)

        if authorization.status.to_i == 4
            text "- Status d'autorisation : Approuvé" 
        end

        move_down(30)

        
        text "- nombre d'heures dans cette autorisation: #{authorization_duration}"
       

        move_down(50)

        two_celule = [[""], [""], [""], [""]]
        my_table = make_table(two_celule)

        table([ ["Visa demandeur                 ", "Visa supérieur hierarchique Maroc", "Visa Responsable  RH               "],
        ["#{authorization.signature_collab.split(/_ */).first}", "#{authorization.signature_g_h.split(/_ */).first}", "#{authorization.signature_g_f.split(/_ */).first}"],
        ["Date : #{authorization.signature_collab.split(/_ */).last}", "Date : #{authorization.signature_g_h.split(/_ */).last}", "Date : #{authorization.signature_g_f.split(/_ */).last}"]])

        move_down(60)

        text "Alithya Numérique Maroc : Place Brahim Roudani, Rue de la Sana, Résidence Beethoven II, 3ème étage, N 82 Tanger, Maroc", :align => :center

    end

end