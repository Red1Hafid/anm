class FurloughPdf < Prawn::Document

    def initialize(furlough, furlough_duration)
        super()

        move_down(40)

        image "#{Rails.root}/app/assets/images/logo.png", :at => [6, 700], :scale => 0.45 

        text "Alithya Numérique Maroc", :align => :right
        move_down(30)
        text "Fait le #{Date.current}", :align => :right

        move_down(30)

        text "Nom : #{furlough.user.last_name}" 

        text "Prénom : #{furlough.user.first_name}"

        move_down(60)
        
        text "Objet : Demande de prise de #{furlough.furlough_type.name.downcase} ! "

        move_down(60)

        text "- Date de début: #{furlough.start.strftime('%d/%m/%Y')} #{furlough.hour_start} h"

        move_down(30)

        if furlough.hour_end == "14:00" 
            text "- Date de fin: #{furlough.end.strftime('%d/%m/%Y')} à #{furlough.hour_end} h"
        else
            text "- Date de fin: #{furlough.end.send(:-, 1.day).strftime('%d/%m/%Y')} à 18:00 h"
        end 

        move_down(30)

        text "- Status de congé : #{furlough.status}" 

        move_down(30)

        if furlough_duration <= 1
            text "- Nombre de jours : une journée #{furlough_duration}"
        else
            text "- Nombre de jours : #{furlough_duration} jours"
        end

        move_down(30)

        if furlough.end.saturday?
            text "Date de reprise : #{furlough.end.strftime('%d/%m/%Y').to_date.send(:+, 2.day)} à 08:00 h", :align => :center
        elsif furlough.end.sunday?
            text "Date de reprise : #{furlough.end.strftime('%d/%m/%Y').to_date.send(:+, 1.day)} à 08:00 h", :align => :center
        else
            text "Date de reprise : #{furlough.end.strftime('%d/%m/%Y')} à #{furlough.hour_end} h", :align => :center
        end

        move_down(50)

        two_celule = [[""], [""], [""], [""]]
        my_table = make_table(two_celule)

        table([ ["Visa demandeur                 ", "Visa supérieur hierarchique Maroc", "Visa Responsable  RH               "],
        ["#{furlough.signature_collab.split(/_ */).first}", "#{furlough.signature_g_h.split(/_ */).first}", "#{furlough.signature_g_f.split(/_ */).first}"],
        ["Date : #{furlough.signature_collab.split(/_ */).last}", "Date : #{furlough.signature_g_h.split(/_ */).last}", "Date : #{furlough.signature_g_f.split(/_ */).last}"]])

        move_down(60)

        text "Alithya Numérique Maroc : Place Brahim Roudani, Rue de la Sana, Résidence Beethoven II, 3ème étage, N 82 Tanger, Maroc", :align => :center

    end

end