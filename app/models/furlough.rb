class Furlough < ApplicationRecord
  serialize :notes, Array
  
  acts_as_tenant :company
  belongs_to :user
  belongs_to :furlough_type

  has_one_attached :documment

  before_create :set_reference

  scope :furloughs_of_adjust, lambda{|year_off_first_off| where('EXTRACT(YEAR from furloughs.end) = ?', year_off_first_off).or(where('EXTRACT(YEAR from furloughs.start) = ?', year_off_first_off))}

  def self.furlough_between(start_date, end_date, user_id)
    furlough_type_not_payed_ids = FurloughType.where(is_payer: false).pluck(:id)
    if start_date == end_date
      furloughs = Furlough.where(user_id: user_id, status: ["Approuvé", "Régularisé", "Arrêté"]).where("furloughs.start >= ? AND furloughs.start <= ?", start_date, end_date.end_of_month).or(where("furloughs.end >= ? AND furloughs.end <= ?", start_date, end_date.end_of_month)).or(where("furloughs.start <= ? AND furloughs.end >= ?", start_date, end_date)).where(furlough_type_id: furlough_type_not_payed_ids).pluck(:start, :hour_start, :end, :hour_end, :status)
    else
      furloughs = Furlough.where("furloughs.start >= ? AND furloughs.start <= ? AND furloughs.user_id = ?", start_date, end_date, user_id).or(where("furloughs.end >= ? AND furloughs.end <= ? AND furloughs.user_id = ?", start_date, end_date, user_id)).or(where("furloughs.start <= ? AND furloughs.end >= ? AND furloughs.user_id = ?", start_date, end_date, user_id)).where(furlough_type_id: furlough_type_not_payed_ids, status: ["Approuvé", "Régularisé", "Arrêté"]).pluck(:start, :hour_start, :end, :hour_end, :status)
    end
    return furloughs
  end

  def self.get_furlough_duration(d1, h1, d2, h2)
    array = []
    Off.off_between(d1, d2).pluck(:start, :end).each { |off| array.concat((off[0].to_date..off[1].to_date).to_a.select {|k| [1,2,3,4,5].include?(k.wday) && (k >= d1) && (k <= d2)})}
    result_week_day = (d1.to_date..d2.to_date).to_a.select {|k| [1,2,3,4,5].include?(k.wday)} - array.uniq

    count_furlough = result_week_day.count
    count_furlough -= 0.5 if (result_week_day.include? d1) && (h1 == "14:00")
    count_furlough -= 0.5 if (result_week_day.include? d2) && (h2 == "14:00")
    count_furlough -= 1 if (result_week_day.include? d2) && (h2 == "8:00")
    
    return count_furlough
  end

  #Not including offs and week days
  def self.days_before_demand(d1, d2)
    array = []
    Off.off_between(d1, d2).pluck(:start, :end).each { |off| array.concat((off[0].to_date..off[1].to_date).to_a.select {|k| [1,2,3,4,5].include?(k.wday)})}
    result_day = (d1.to_date..d2.to_date).to_a.select {|k| [1,2,3,4,5].include?(k.wday)} - array

    return result_day
  end

  def self.get_balance_current_month(user)
    setting = Setting.find(1)
    if user.started_at <= Date.today
      if user.started_at >= Date.today.beginning_of_month
        days_worked = Furlough.get_days_worked_between_two_date(user, user.started_at, Date.today)
      else
        days_worked = Furlough.get_days_worked_between_two_date(user, Date.today.beginning_of_month, Date.today)
      end
      balance_current_month = days_worked >= 26 ? setting.month_balance : (setting.month_balance / 26.to_f ) * days_worked
    end

    return balance_current_month
  end

  def self.get_days_worked_between_two_date(user, date_start, date_end)
    counter = 0.0
    days_furloughs = []

    days_worked_between_two_date = (date_start..date_end).to_a.select {|k| [1,2,3,4,5,6].include?(k.wday)}  
    Furlough.furlough_between(date_start, date_end, user.id).each { |furlough| days_furloughs.concat((furlough[0].to_date..furlough[2].to_date).to_a.select {|k| [1,2,3,4,5].include?(k.wday) && (k >= date_start) && (k <= date_end)})
      counter += 0.5 if (days_furloughs.include? furlough[0]) && (furlough[1] == "14:00") 
      counter += 0.5 if (days_furloughs.include? furlough[2]) && (furlough[3] == "14:00")
      counter -= 1 if (days_furloughs.include? furlough[2]) && (furlough[3] == "8:00")
    }

    days_worked = (days_worked_between_two_date.count - days_furloughs.uniq.count) - counter

    return days_worked   
  end

  def set_reference
    return if self.reference_furlough != nil
    furlough = Furlough.last
    if furlough
      thereference = "cg#" + (furlough.id + 1).to_s
    else
      thereference = "cg#1"
    end
    
    self.reference_furlough = thereference
    set_reference if Furlough.find_by(reference_furlough: thereference)
  end

  def self.rh_create_collab_furlough(specification, furlough, furlough_type, current_user, user_furlough)
    if specification[:danger].count == 0 && specification[:is_furlough] == true && furlough_type.code == 'CRHS' 
      role = Role.find(current_user.role_id)
      content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à demmandé un congé de récuperation des heures sup. des jours férié á partir de #{furlough.start} jusqu'a #{furlough.end} - date de créaction : #{Time.now}"
      furlough.user_id = user_furlough.id
      furlough.notes = specification[:notes]
      furlough.status = "En cours"
      furlough.signature_collab = "Approuvé par " + furlough.user.first_name + " " + furlough.user.last_name + " _" + " Le " + DateTime.now().strftime("%m/%d/%Y").to_s + DateTime.now().strftime(" à %I:%M%p").to_s
      furlough.signature_g_h = "  :" + "  "
      furlough.signature_g_f = "Approuvé par " + current_user.first_name + " " + current_user.last_name + " _" + " Le " + DateTime.now().strftime("%m/%d/%Y").to_s + DateTime.now().strftime(" à %I:%M%p").to_s
      furlough.save
      Journal.create_journal(current_user, furlough, "En cours", content, "furlough")
      etat = {info:  "Votre demande de congé à été bien crée", status: 200 }
    elsif !(specification[:danger].any? { |i| ["La date de début de congé ne doit pas être superieur à la date de fin de ce congé", "La date de début de ce congé est inférieure a la date de naissance du fils"].include? i }) 
      if specification[:is_furlough] == true
        if specification[:warning].include? "La date de début de congé ne doit pas être inferieur à la date du jour"
          if ['CEFMA', 'CEFNE', 'CEFOC', 'CEFDA', 'CEFDF'].include? furlough_type.code
            if specification[:danger].include? "Vous ne pouvez pas dépassé #{furlough_type.max_duration} jours pour ce congé"
              etat = {info:  "Votre demande de congé n'à pas été crée", status: 404 }
            else
              if specification[:is_furlough] == true
                furlough.status = "En cours" 
                furlough.notes = specification[:notes]
                furlough.signature_collab = "Approuvé par " + furlough.user.first_name + " " + furlough.user.last_name + " _" + " Le " + DateTime.now().strftime("%m/%d/%Y").to_s + DateTime.now().strftime(" à %I:%M%p").to_s
                g_h = User.find(user_furlough.line_manager_id)
                furlough.signature_g_h = "Approuvé par " + g_h.first_name + " " + g_h.last_name + " _" + " Le " + DateTime.now().strftime("%m/%d/%Y").to_s + DateTime.now().strftime(" à %I:%M%p").to_s
                furlough.signature_g_f = "Approuvé par " + current_user.first_name + " " + current_user.last_name + " _" + " Le " + DateTime.now().strftime("%m/%d/%Y").to_s + DateTime.now().strftime(" à %I:%M%p").to_s
                furlough.save 
                role = Role.find(current_user.role_id)
                content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à demmandé un congé á partir de #{furlough.start} jusqu'a #{furlough.end} pour le collaborateur #{user_furlough.first_name} #{user_furlough.last_name} - date de créaction : #{Time.now}"
                Journal.create_journal(current_user, furlough, "En cours", content, "furlough")
                etat = {info:  "Votre demande de congé à été bien crée", status: 200 }
              end
            end
          else
            etat = {info:  "Votre demande de congé n'à pas été crée", status: 404 }
          end
        else
          if specification[:danger].include? "Vous ne pouvez pas dépassé #{furlough_type.max_duration} jours pour ce congé"
            etat = {info:  "Votre demande de congé n'à pas été crée", status: 404 }
          else
            furlough.status = "En cours" 
            furlough.notes = specification[:notes]
            furlough.signature_collab = "Approuvé par " + furlough.user.first_name + " " + furlough.user.last_name + " _" + " Le " + DateTime.now().strftime("%m/%d/%Y").to_s + DateTime.now().strftime(" à %I:%M%p").to_s 
            if !user_furlough.line_manager_id.blank?
              g_h = User.find(user_furlough.line_manager_id)
              furlough.signature_g_h = "Approuvé par " + g_h.first_name + " " + g_h.last_name + " _" + " Le " + DateTime.now().strftime("%m/%d/%Y").to_s + DateTime.now().strftime(" à %I:%M%p").to_s 
            else
              furlough.signature_g_h = " "
            end
            furlough.signature_g_f = "Approuvé par " + current_user.first_name + " " + current_user.last_name + " _" + " Le " + DateTime.now().strftime("%m/%d/%Y").to_s + DateTime.now().strftime(" à %I:%M%p").to_s
            furlough.save 
            role = Role.find(current_user.role_id)
            content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à demmandé un congé á partir de #{furlough.start} jusqu'a #{furlough.end} pour le collaborateur #{user_furlough.first_name} #{user_furlough.last_name} - date de créaction : #{Time.now}"
            Journal.create_journal(current_user, furlough, "En cours", content, "furlough")
            etat = {info:  "Votre demande de congé à été bien crée", status: 200 }
          end   
        end
      else
        etat = {info:  "Votre demande de congé n'à pas été crée", status: 404 }
      end
    else
      etat = {info:  "Votre demande de congé n'à pas été crée", status: 404 }
    end

    return etat
  end

  def self.rh_update_collab_furlough(specification, furlough_params, furlough, furlough_type, current_user, user_furlough)
    if ["Approuvé", "Soumis"].include? furlough.status
      furlough.documment.purge 
      furlough.documment.attach(furlough_params[:documment])
      furlough.save
      role = Role.find(current_user.role_id)
      content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à inséré la piéce joint pour le congé avec la référence #{furlough.reference_furlough} pour le collaborateur #{user_furlough.first_name} #{user_furlough.last_name} - date de créaction : #{Time.now}"
      Journal.create_journal(current_user, furlough, "Updated", content, "furlough")
      etat = {info:  "Votre demande de congé à été bien modifié", status: 200 }
    else
      if !(specification[:danger].any? { |i| ["La date de début de congé ne doit pas être superieur à la date de fin de ce congé", "La date de début de ce congé est inférieure a la date de naissance du fils"].include? i }) 
        if specification[:is_furlough] == true
          if specification[:warning].include? "La date de début de congé ne doit pas être inferieur à la date du jour"
            if ['CEFMA', 'CEFNE', 'CEFOC', 'CEFDA', 'CEFDF'].include? furlough_type.code
              if specification[:danger].include? "Vous ne pouvez pas dépassé #{furlough_type.max_duration} jours pour ce congé"
                etat = {info:  "Votre demande de congé n'à pas été crée", status: 404 }
              else
                if specification[:is_furlough] == true
                  furlough.update(furlough_params)
                  furlough.notes = specification[:notes]
                  furlough.documment.purge 
                  furlough.documment.attach(furlough_params[:documment])
                  furlough.save
                  role = Role.find(current_user.role_id)
                  content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à modifié un congé á partir de #{furlough_params[:start]} jusqu'a #{furlough_params[:end]} pour le collaborateur #{user_furlough.first_name} #{user_furlough.last_name} - date de créaction : #{Time.now}"
                  Journal.create_journal(current_user, furlough, "Updated", content, "furlough")
                  etat = {info:  "Votre demande de congé à été bien modifié", status: 200 }
                end
              end
            else
              etat = {info:  "Votre demande de congé n'à pas été modifié", status: 404 }
            end
          else
            if specification[:danger].include? "Vous ne pouvez pas dépassé #{furlough_type.max_duration} jours pour ce congé"
              etat = {info:  "Votre demande de congé n'à pas été crée", status: 404 }
            else
              furlough.update(furlough_params)
              furlough.notes = specification[:notes]
              furlough.documment.purge 
              furlough.documment.attach(furlough_params[:documment])
              furlough.save
              role = Role.find(current_user.role_id)
              content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à modifié un congé á partir de #{furlough_params[:start]} jusqu'a #{furlough_params[:end]} pour le collaborateur #{user_furlough.first_name} #{user_furlough.last_name} - date de créaction : #{Time.now}"
              Journal.create_journal(current_user, furlough, "Updated", content, "furlough")
              etat = {info:  "Votre demande de congé à été bien modifié", status: 200 }
            end   
          end
        else
          etat = {info:  "Votre demande de congé n'à pas été modifié", status: 404 }
        end
      else
        etat = {info:  "Votre demande de congé n'à pas été modifié", status: 404 }
      end
    end
   

    return etat
  end

  def self.rh_create_self_furlough(specification, furlough, furlough_type, current_user, user_furlough)
    if specification[:danger].count == 0 && specification[:is_furlough] == true && furlough_type.code == 'CRHS' 
      role = Role.find(current_user.role_id)
      content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à demmandé un congé de récuperation des heures sup. des jours férié á partir de #{furlough.start} jusqu'a #{furlough.end} - date de créaction : #{Time.now}"
      furlough.user_id = user_furlough.id
      furlough.notes = specification[:notes]
      furlough.status = "Nouveau"
      furlough.signature_collab = "Approuvé par " + furlough.user.first_name + " " + furlough.user.last_name + " _" + " Le " + DateTime.now().strftime("%m/%d/%Y").to_s + DateTime.now().strftime(" à %I:%M%p").to_s
      furlough.signature_g_h = "  :" + "  "
      furlough.signature_g_f = "  :" + "  "
      furlough.save
      Journal.create_journal(current_user, furlough, "Nouveau", content, "furlough")
      etat = {info:  "Votre demande de congé à été bien crée", status: 200 }
    elsif !(specification[:danger].any? { |i| ["La date de début de congé ne doit pas être superieur à la date de fin de ce congé", "La date de début de ce congé est inférieure a la date de naissance du fils"].include? i })
      if specification[:is_furlough] == true  
        role = Role.find(user_furlough.role_id)
        content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à demmandé un congé á partir de #{furlough.start} jusqu'a #{furlough.end} - date de créaction : #{Time.now}"
        if specification[:danger].count == 0
          if specification[:warning].include? "La date de début de congé ne doit pas être inferieur à la date du jour"
            if ['CEFMA', 'CEFNE', 'CEFOC', 'CEFDA', 'CEFDF'].include? furlough_type.code
              furlough.status = "Nouveau"  
              furlough.user_id = current_user.id
              furlough.notes = specification[:notes]
              furlough.signature_collab = "Approuvé par " + current_user.first_name + " " + current_user.last_name + " _" + " Le " + DateTime.now().strftime("%m/%d/%Y").to_s + DateTime.now().strftime(" à %I:%M%p").to_s
              furlough.signature_g_h = "  :" + "  "
              furlough.signature_g_f = "  :" + "  "
              furlough.save
              Journal.create_journal(current_user, furlough, "Nouveau", content, "furlough")
              etat = {info:  "Votre demande de congé à été bien crée", status: 200 }
            else
              etat = {info:  "Votre demande de congé n'à pas été crée", status: 404 }
            end
          else
            furlough.status = "Nouveau"  
            furlough.user_id = current_user.id
            furlough.notes = specification[:notes]
            furlough.signature_collab = "Approuvé par " + current_user.first_name + " " + current_user.last_name + " _" + " Le " + DateTime.now().strftime("%m/%d/%Y").to_s + DateTime.now().strftime(" à %I:%M%p").to_s
            furlough.signature_g_h = "  :" + "  "
            furlough.signature_g_f = "  :" + "  "
            furlough.save
            Journal.create_journal(current_user, furlough, "Nouveau", content, "furlough")
            etat = {info:  "Votre demande de congé à été bien crée", status: 200 }
          end
        else
          etat = {info:  "Votre demande de congé n'à pas été crée", status: 404 }
        end
      else
        etat = {info:  "Votre demande de congé n'à pas été crée", status: 404 }
      end
    else
      etat = {info:  "Votre demande de congé n'à pas été crée", status: 404 }
    end
  end

  def self.rh_update_self_furlough(specification, furlough_params, furlough, furlough_type, current_user, user_furlough)
    if ["Approuvé", "Soumis"].include? furlough.status
      furlough.documment.purge 
      furlough.documment.attach(furlough_params[:documment])
      furlough.save
      role = Role.find(current_user.role_id)
      content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à inséré la piéce joint pour le congé avec la référence #{furlough.reference_furlough} pour lui même  - date de modification : #{Time.now}"
      Journal.create_journal(current_user, furlough, "Updated", content, "furlough")
      etat = {info:  "Votre demande de congé à été bien modifié", status: 200 }
    else
      if !(specification[:danger].any? { |i| ["La date de début de congé ne doit pas être superieur à la date de fin de ce congé", "La date de début de ce congé est inférieure a la date de naissance du fils"].include? i })
        if specification[:is_furlough] == true  
          role = Role.find(user_furlough.role_id)
          content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à modifié un congé á partir de #{furlough_params[:start]} jusqu'a #{furlough_params[:end]} - date de créaction : #{Time.now}"
          if specification[:danger].count == 0
            if specification[:warning].include? "La date de début de congé ne doit pas être inferieur à la date du jour"
              if ['CEFMA', 'CEFNE', 'CEFOC', 'CEFDA', 'CEFDF'].include? furlough_type.code
                furlough.update(furlough_params)
                furlough.notes = specification[:notes]
                furlough.documment.purge 
                furlough.documment.attach(furlough_params[:documment])
                furlough.save
                Journal.create_journal(current_user, furlough, "Updated", content, "furlough")
                etat = {info:  "Votre demande de congé à été bien modifié", status: 200 }
              else
                etat = {info:  "Votre demande de congé n'à pas été modifié", status: 404 }
              end
            else
              furlough.update(furlough_params)
              furlough.notes = specification[:notes]
              furlough.documment.purge 
              furlough.documment.attach(furlough_params[:documment])
              furlough.save
              Journal.create_journal(current_user, furlough, "Updated", content, "furlough")
              etat = {info:  "Votre demande de congé à été bien modifié", status: 200 }
            end
          else
            etat = {info:  "Votre demande de congé n'à pas été modifié", status: 404 }
          end
        else
          etat = {info:  "Votre demande de congé n'à pas été modifié", status: 404 }
        end
      else
        etat = {info:  "Votre demande de congé n'à pas été modifié", status: 404 }
      end
    end
  end

  def self.collab_create_self_furlough(specification, furlough, furlough_type, current_user, user_furlough)
    if specification[:danger].count == 0 && specification[:is_furlough] == true 
      role = Role.find(user_furlough.role_id)
      if furlough_type.code == 'CRHS'
        content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à demmandé un congé de récuperation des heures sup. des jours férié á partir de #{furlough.start} jusqu'a #{furlough.end} - date de créaction : #{Time.now}"
        furlough.user_id = current_user.id
        furlough.notes = specification[:notes]
        furlough.status = "Nouveau"
        furlough.signature_collab = "Approuvé par " + furlough.user.first_name + " " + furlough.user.last_name + " _" + " Le " + DateTime.now().strftime("%m/%d/%Y").to_s + DateTime.now().strftime(" à %I:%M%p").to_s
        furlough.signature_g_h = "  :" + "  "
        furlough.signature_g_f = "  :" + "  "
        furlough.save
        Journal.create_journal(current_user, furlough, "Nouveau", content, "furlough")
        etat = {info:  "Votre demande de congé à été bien crée", status: 200 }
      else
        content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à demmandé un congé á partir de #{furlough.start} jusqu'a #{furlough.end} - date de créaction : #{Time.now}"
        if specification[:warning].include? "La date de début de congé ne doit pas être inferieur à la date du jour"
          if ['CEFMA', 'CEFNE', 'CEFOC', 'CEFDA', 'CEFDF'].include? furlough_type.code
            furlough.status = "Nouveau"  
            furlough.user_id = current_user.id
            furlough.notes = specification[:notes]
            furlough.signature_collab = "Approuvé par " + current_user.first_name + " " + current_user.last_name + " _" + " Le " + DateTime.now().strftime("%m/%d/%Y").to_s + DateTime.now().strftime(" à %I:%M%p").to_s
            furlough.signature_g_h = "  :" + "  "
            furlough.signature_g_f = "  :" + "  "
            furlough.save
            Journal.create_journal(current_user, furlough, "Nouveau", content, "furlough")
            etat = {info:  "Votre demande de congé à été bien crée", status: 200 }
          else
            etat = {info:  "Votre demande de congé n'à pas été crée", status: 404 }
          end
        else
          furlough.status = "Nouveau"  
          furlough.user_id = current_user.id
          furlough.notes = specification[:notes]
          furlough.signature_collab = "Approuvé par " + current_user.first_name + " " + current_user.last_name + " _" + " Le " + DateTime.now().strftime("%m/%d/%Y").to_s + DateTime.now().strftime(" à %I:%M%p").to_s
          furlough.signature_g_h = "  :" + "  "
          furlough.signature_g_f = "  :" + "  "
          furlough.save
          Journal.create_journal(current_user, furlough, "Nouveau", content, "furlough")
          etat = {info:  "Votre demande de congé à été bien crée", status: 200 }
        end
      end
    else
      etat = {info:  "Votre demande de congé n'à pas été crée", status: 404 }
    end
  end

  def self.collab_update_self_furlough(specification, furlough_params, furlough, furlough_type, current_user, user_furlough)
    if specification[:danger].count == 0 && specification[:is_furlough] == true 
      role = Role.find(user_furlough.role_id)
      content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à modifié un congé á partir de #{furlough_params[:start]} jusqu'a #{furlough_params[:end]} - date de créaction : #{Time.now}"
      if specification[:warning].include? "La date de début de congé ne doit pas être inferieur à la date du jour"
        if ['CEFMA', 'CEFNE', 'CEFOC', 'CEFDA', 'CEFDF'].include? furlough_type.code
          furlough.update(furlough_params)
          furlough.notes = specification[:notes]
          furlough.documment.purge 
          furlough.documment.attach(furlough_params[:documment])
          Journal.create_journal(current_user, furlough, "Updated", content, "furlough")
          etat = {info:  "Votre demande de congé à été bien modifié", status: 200 }
        else
          etat = {info:  "Votre demande de congé n'à pas été modifié", status: 404 }
        end
      else
        furlough.update(furlough_params)
        furlough.notes = specification[:notes]
        furlough.documment.purge 
        furlough.documment.attach(furlough_params[:documment])
        furlough.save
        Journal.create_journal(current_user, furlough, "Updated", content, "furlough")
        etat = {info:  "Votre demande de congé à été bien modifié", status: 200 }
      end
    else
      etat = {info:  "Votre demande de congé n'à pas été modifié", status: 404 }
    end
  end

  def self.get_furlough_specification(furlough, user)
    bank = Bank.find_by(user_id: user.id)
    furlough_type = FurloughType.find(furlough.furlough_type_id)
    setting = Setting.find(1)

    warning = []
    danger = []
    notes = []
    is_furlough = true

    if furlough_type.code == 'CRHS'
      furlough_hour_duration = get_furlough_duration(furlough.start, furlough.hour_start, furlough.end, furlough.hour_end) * 8

      if furlough.start.to_datetime.mjd < Date.current.mjd
        danger << "La date de début de congé ne doit pas être inferieur à la date du jour"
        notes << "La date de début de congé ne doit pas être inferieur à la date du jour"
      elsif furlough.start > furlough.end
        danger << "La date de début de congé ne doit pas être superieur à la date de fin de ce congé"
      else
        results = HoursValidity.get_valid_hours_2(user.id, furlough.start, furlough.hour_start, furlough.end, furlough.hour_end)
        if furlough_hour_duration > results[:hour_valide_in_period]
          if results[:hour_valide_in_period] > 0
            danger << "Sur la periode du congé demmandé vous avez droit juste de " + results[:hour_valide_in_period].to_s + "h"
          else
            danger << "vous n'avez pas d'heures sup sur la période demmandé"
          end
          notes << "dépassé le nombre d'heures sup"
        end
        if furlough_hour_duration < 1 
          is_furlough = false
        end

        if !furlough.documment.attached? && furlough_type.code == "CRHS"
          danger << "l'accord du gesstionnaire fonctionnel est obligatoire"
          is_furlough = false
        end
      end

      specification = { warning: warning, danger: danger, notes: notes, is_furlough: is_furlough, results: results }
    else
      furlough_duration = get_furlough_duration(furlough.start, furlough.hour_start, furlough.end, furlough.hour_end)

      if furlough.start.to_datetime.mjd < Date.current.mjd
        warning << "La date de début de congé ne doit pas être inferieur à la date du jour"
        notes << "La date de début de congé ne doit pas être inferieur à la date du jour"
  
        if furlough_type.code == "CEFNE" && (furlough.start.to_datetime.mjd < furlough.child_date.to_datetime.mjd)
          danger << "La date de début de ce congé est inférieure a la date de naissance du fils"
        end
      elsif furlough.start > furlough.end
        danger << "La date de début de congé ne doit pas être superieur à la date de fin de ce congé"
      else
        if furlough_duration > bank.balance_furlough && furlough_type.code != "CSS"
          warning << "vous avez dépassé le solde de congé"
          notes << "dépassé le solde de congé"
        end
        if furlough_duration < 1 
          is_furlough = false
        end
        if furlough_type.fixed_duration
          if furlough_duration > furlough_type.max_duration
            danger << "Vous ne pouvez pas dépassé #{furlough_type.max_duration} jours pour ce congé"
          end
        end
        if furlough_type.informing_before
          days = days_before_demand(Date.today, furlough.start)
          if days.count * 24 < (setting.informing_before_duration + 1)
            danger << "Ce type de congé demande une duré de déclaration de 48h"
          end  
        end
      end
  
      if (furlough.start.to_datetime.mjd - user.started_at.to_datetime.mjd) < 210
        warning << "Vous n'avez pas encore dépassé les 7 mois pour être convoquer a demandé un congé"
        notes << "pas encore dépassé les 7 mois pour être convoquer a demandé un congé"
      end
  
      if !furlough.documment.attached? && furlough_type.code == "CPA"
        danger << "l'accord du gesstionnaire fonctionnel est obligatoire"
      end
  
      specification = { warning: warning, danger: danger, notes: notes, is_furlough: is_furlough }
    end

    return specification
  end

  def self.get_update_furlough_specification(furlough_params, user, furlough)
    if ["Approuvé", "Soumis"].include? furlough.status
      specification = { warning: [], danger: [], notes: [], is_furlough: [] }
      return specification
    else
      bank = Bank.find_by(user_id: user.id)
      furlough_duration = get_furlough_duration(furlough_params[:start], furlough_params[:hour_start], furlough_params[:end], furlough_params[:hour_end])
      furlough_type = FurloughType.find(furlough_params[:furlough_type_id])
      setting = Setting.find(1)
  
      warning = []
      danger = []
      notes = []
      is_furlough = true
  
      if furlough_params[:start].to_datetime.mjd < Date.current.mjd
        warning << "La date de début de congé ne doit pas être inferieur à la date du jour"
        notes << "La date de début de congé ne doit pas être inferieur à la date du jour"
      elsif furlough_params[:start] > furlough_params[:end]
        danger << "La date de début de congé ne doit pas être superieur à la date de fin de ce congé"
      else
        if furlough_duration > bank.balance_furlough && furlough_type.code != "CSS"
          warning << "vous avez dépassé le solde de congé"
          notes << "dépassé le solde de congé"
        end
        if furlough_duration < 1 
          is_furlough = false
        end
        if furlough_type.fixed_duration
          if furlough_duration > furlough_type.max_duration
            danger << "Vous ne pouvez pas dépassé #{furlough_type.max_duration} jours pour ce congé"
          end
        end
        if furlough_type.informing_before
          days = days_before_demand(Date.today, furlough_params[:start])
          if days.count * 24 < (setting.informing_before_duration + 1)
            danger << "Ce type de congé demande une duré de déclaration de 48h"
          end  
        end
      end
  
      if (furlough_params[:start].to_datetime.mjd - user.started_at.to_datetime.mjd) < 210
        warning << "Vous n'avez pas encore dépassé les 7 mois pour être convoquer a demandé un congé"
        notes << "pas encore dépassé les 7 mois pour être convoquer a demandé un congé"
      end
  
      if !furlough_params[:documment] && furlough_type.code == "CPA"
        danger << "l'accord du gesstionnaire fonctionnel est obligatoire"
      end
  
      specification = { warning: warning, danger: danger, notes: notes, is_furlough: is_furlough }
  
      return specification
    end
  end

  def self.custom_finder(date_start, hour_start, date_end, hour_end, user_id, furlough_type_id, status)
    furlough = Furlough.find_by(start: date_start, hour_start: hour_start, end: date_end, hour_end: hour_end, user_id: user_id, furlough_type_id: furlough_type_id, status: status)
    if furlough.present?
     return true
    else
      return false
    end
  end

  def self.is_week_day(end_date)
    is_week_day = false
    if end_date.to_date.sunday? || end_date.to_date.saturday?
      is_week_day = true
    end
    return is_week_day
  end
end
