class TemplateAttestationPdf < Prawn::Document

    def initialize(p1, p2, p3, footer_pdf, template_name, rh, user_conf)
        super()

        move_down(40)

        image "#{Rails.root}/app/assets/images/logo.png", :at => [6, 700], :scale => 0.45 

        text "Alithya Numérique Maroc", :align => :right
        move_down(30)
        text "Fait le #{Date.current}", :align => :right

        move_down(80)

        text "#{template_name.name}", :align => :center, :size => 18

        move_down(60)

        text "#{p1}"

        move_down(20)

        text "#{p2}"

        move_down(20)

        text "#{p3}"

        move_down(70)

        text "Mme #{rh.first_name} #{rh.last_name}", :align => :right, :size => 14
        move_down(10)
        text "#{rh.job_title}", :align => :right, :size => 14
        move_down(10)
        image ActiveStorage::Blob.service.send(:path_for, user_conf.cachet.key), position: :right, :scale => 0.30
       

        move_down(90)

        text "#{footer_pdf}", :align => :center, :size => 8

    end

end