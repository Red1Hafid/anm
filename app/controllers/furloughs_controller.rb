class FurloughsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_furlough, only: [:pre_stop, :stop, :pre_regularized, :regularized, :pre_discontinuity, :discontinuity, :show_administration, :to_print, :show, :edit, :update, :destroy, :validate, :pre_refuse, :refuse, :pre_cancel, :cancel, :soumettre, :pre_valide_fc, :valide_fc]
  #load_and_authorize_resource

  def index
    @q = Furlough.ransack(params[:q])
    @setting = Setting.find(1)
    if ["Super Admin", "Rh"].include? current_user.role.title 
      if params[:status].present? && ['En cours', 'Nouveau', 'Approuvé', 'Refusé', 'Soumis', 'Annulé'].include?(params[:status]) == true
        @furloughs = Furlough.where(status: params[:status]).order(reference_furlough: :desc)
      elsif params[:attached].present?
        furloughs_type_ids = FurloughType.where(code: ['CEFMC', 'CEFME', 'CEFCE', 'CEFOC', 'CEFDA', 'CEFDF', 'CEFNE', 'CEFDC', 'CEFMA']).pluck(:id)
        @furloughs = []
        Furlough.where(furlough_type_id: furloughs_type_ids, status: ["Soumis", "Approuvé"]).each do |f| 
          if !f.documment.attached?
            @furloughs.push(f)
          end
        end 
      else
        @furloughs = @q.result(distinct: true).where.not(status: "Nouveau").order(reference_furlough: :desc)
      end
      users_not_actif_ids = User.where(is_active: false).pluck(:id)

      @users = User.all.where.not(id: [current_user.id]).where.not(id: users_not_actif_ids)
    else
      if params[:status].present? && ['En cours', 'Nouveau', 'Approuvé', 'Refusé', 'Soumis', 'Annulé'].include?(params[:status]) == true
        @furloughs = Furlough.where(user_id: current_user, status: params[:status]).order(reference_furlough: :desc)
      else
        @furloughs = @q.result(distinct: true).where(user_id: current_user).order(reference_furlough: :desc)
      end
      @balance_furlough_day = Bank.find_by(user_id: current_user).balance_furlough
      @balance_furlough_day_réel = Furlough.get_balance_current_month(current_user.id)
      @balance_d = (@balance_furlough_day + @balance_furlough_day_réel).round(2)
      @balance_h = (@balance_d * @setting.day_work_hour).round(2)
      @date_now = DateTime.now.to_date.send(:-, 1.day).strftime('%d/%m/%Y')
    end

    respond_to do |format|
      format.xlsx
      format.html { render :index }
      format.csv
    end
  end

  def furloughs_administration
    @q = Furlough.ransack(params[:q])
    @furloughs_admin = @q.result(distinct: true).where(user_id: current_user).order(reference_furlough: :desc)
    bank = Bank.find_by(user_id: current_user)
    setting = Setting.find(1)
 
    @balance_furlough_day = bank.balance_furlough
    @balance_furlough_h = bank.balance_furlough * setting.day_work_hour
    @balance_furlough_day_réel = Furlough.get_balance_current_month(current_user.id)
    @balance_d = (@balance_furlough_day + @balance_furlough_day_réel).round(2)
    @balance_h = (@balance_d * setting.day_work_hour).round(2)
    @date_now = DateTime.now.to_date.send(:-, 1.day).strftime('%d/%m/%Y')
  end

  def show_administration
    @journals_furlough = Journal.where(the_model: 'furlough', the_model_id: @furlough.id).where.not(status: "Updated").order('created_at asc')
    @furlough_duration_by_days= Furlough.get_furlough_duration(@furlough.start, @furlough.hour_start, @furlough.end, @furlough.hour_end) 
    @furlough_duration_by_hours = @furlough_duration_by_days * 8
  end

  def show   
    @journals_furlough = Journal.where(the_model: 'furlough', the_model_id: @furlough.id).where.not(status: "Updated").order('created_at asc')
    @furlough_duration_by_days= Furlough.get_furlough_duration(@furlough.start, @furlough.hour_start, @furlough.end, @furlough.hour_end) 
    @furlough_duration_by_hours = @furlough_duration_by_days * 8

    if !@furlough.parent_id.nil?
      @paren_discontinuity = Furlough.find(@furlough.parent_id)
    end

    @childs_discontinuity = Furlough.where(parent_id: @furlough.id)
   

   
    @furlough_regular = Furlough.find(@furlough.furlough_regular_id) if !@furlough.furlough_regular_id.nil?
  end

  def new
    @furlough = Furlough.new 
    @balance_furlough_day = Bank.find_by(user_id: current_user).balance_furlough

    @balance_furlough_day_réel = Furlough.get_balance_current_month(current_user.id)
    @balance_d = (@balance_furlough_day + @balance_furlough_day_réel).round(2)
    @balance_h = (@balance_d * 8).round(2)
    @date_now = DateTime.now.to_date.send(:-, 1.day).strftime('%d/%m/%Y')
    if ["Super Admin", "Rh"].include? current_user.role.title 
      @users = User.all.where.not(id: [current_user.id])
    end  
  end

  def create
    @furlough = Furlough.new(furlough_params)
    furlough_type = FurloughType.find(@furlough.furlough_type_id)

    if ['Super Admin', 'Rh'].include? current_user.role.title
      if @furlough.user_id.present? && @furlough.user_id != current_user.id
        user_furlough = User.find(@furlough.user_id)
        specification = Furlough.get_furlough_specification(@furlough, user_furlough)
        etat = Furlough.rh_create_collab_furlough(specification, @furlough, furlough_type, current_user, user_furlough)
        flash[:danger] = specification[:danger]
        flash[:warning] = specification[:warning]
        if etat[:status] == 200
          redirect_to furloughs_path, success: etat[:info] 
        else 
          redirect_to furloughs_path, info: etat[:info] 
        end
      else
        @furlough = Furlough.new(furlough_self_params)
        user_furlough = User.find(current_user.id)
        specification = Furlough.get_furlough_specification(@furlough, user_furlough)
        etat = Furlough.rh_create_self_furlough(specification, @furlough, furlough_type, current_user, user_furlough)
        flash[:danger] = specification[:danger]
        flash[:warning] = specification[:warning]
        if etat[:status] == 200
          redirect_to furloughs_administration_path, success: etat[:info] 
        else 
          redirect_to furloughs_administration_path, info: etat[:info] 
        end
      end
    else 
      @furlough = Furlough.new(furlough_self_params)
      user_furlough = User.find(current_user.id)
      specification = Furlough.get_furlough_specification(@furlough, user_furlough)
      etat = Furlough.collab_create_self_furlough(specification, @furlough, furlough_type, current_user, user_furlough)
      flash[:danger] = specification[:danger]
      flash[:warning] = specification[:warning]
      if etat[:status] == 200
        redirect_to furloughs_path, success: etat[:info] 
      else 
        redirect_to furloughs_path, info: etat[:info] 
      end
    end
  end

  def edit
    users_not_actif_ids = User.where(is_active: false).pluck(:id)
    @users = User.all.where.not(id: [current_user.id]).where.not(id: users_not_actif_ids)
  end

  def update
    furlough_type = FurloughType.find(@furlough.furlough_type_id)
    if ["Approuvé", "Soumis"].include? @furlough.status
        user_furlough = User.find(@furlough.user_id)
       if params[:documment].present?
          specification = Furlough.get_update_furlough_specification(furlough_params, user_furlough, @furlough)
          etat = Furlough.rh_update_collab_furlough(specification, furlough_params, @furlough, furlough_type, current_user, user_furlough)
        else
          specification = Furlough.get_update_furlough_specification(u_furlough_attached_params, user_furlough, @furlough)
          etat = Furlough.rh_update_collab_furlough(specification, u_furlough_attached_params, @furlough, furlough_type, current_user, user_furlough)
        end
        if etat[:status] == 200
          redirect_to furloughs_path, success: etat[:info] 
        else 
          redirect_to furloughs_path, info: etat[:info] 
        end
    else
      if ['Super Admin', 'Rh'].include? current_user.role.title
        if furlough_params[:user_id].present? && furlough_params[:user_id] != current_user.id
          user_furlough = User.find(furlough_params[:user_id])
          specification = Furlough.get_update_furlough_specification(furlough_params, user_furlough, @furlough)
          etat = Furlough.rh_update_collab_furlough(specification, furlough_params, @furlough, furlough_type, current_user, user_furlough)
          flash[:danger] = specification[:danger]
          flash[:warning] = specification[:warning]
          if etat[:status] == 200
            redirect_to furloughs_path, success: etat[:info] 
          else 
            redirect_to furloughs_path, info: etat[:info] 
          end
        else
          user_furlough = User.find(current_user.id)
          specification = Furlough.get_update_furlough_specification(furlough_params, user_furlough, @furlough)
          etat = Furlough.rh_update_self_furlough(specification, furlough_params, @furlough, furlough_type, current_user, user_furlough)
          flash[:danger] = specification[:danger]
          flash[:warning] = specification[:warning]
          if etat[:status] == 200
            redirect_to furloughs_administration_path, success: etat[:info] 
          else 
            redirect_to furloughs_administration_path, info: etat[:info] 
          end
        end
      else 
        user_furlough = User.find(current_user.id)
        specification = Furlough.get_update_furlough_specification(furlough_params, user_furlough, @furlough)
        etat = Furlough.collab_update_self_furlough(specification, furlough_params, @furlough, furlough_type, current_user, user_furlough)
        flash[:danger] = specification[:danger]
        flash[:warning] = specification[:warning]
        if etat[:status] == 200
          redirect_to furloughs_path, success: etat[:info] 
        else 
          redirect_to furloughs_path, info: etat[:info] 
        end
      end
    end
  end

  def destroy
    @furlough.destroy
    role = Role.find(current_user.role_id)
    content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à supprimé un congé á partir de #{@furlough.start} jusqu'a #{@furlough.end} - loger le : #{Time.now}"
    Journal.create_journal(current_user, @furlough, "Deleted", content, "furlough")
    if ['Super Admin', 'Rh'].include? current_user.role.title
      if @furlough.user_id == current_user.id
        redirect_to furloughs_administration_path
      else
        redirect_to furloughs_path  
      end
    else 
      redirect_to furloughs_path
    end
  end

  def validate 
    user_furlough = User.find(@furlough.user_id)
    if !user_furlough.line_manager_id.blank?
      g_h = User.find(user_furlough.line_manager_id) 
      @furlough.update(status: "Approuvé", color: "green", signature_g_h: "Approuvé par " + g_h.first_name + " " + g_h.last_name + " _" + " Le " + DateTime.now().strftime("%m/%d/%Y").to_s + DateTime.now().strftime(" à %I:%M%p").to_s, signature_g_f: "Approuvé par " + current_user.first_name + " " + current_user.last_name + " _" + " Le " + DateTime.now().strftime("%m/%d/%Y").to_s + DateTime.now().strftime(" à %I:%M%p").to_s)
    else 
      @furlough.update(status: "Approuvé", color: "green", signature_g_h: " ", signature_g_f: "Approuvé par " + current_user.first_name + " " + current_user.last_name + " _" + " Le " + DateTime.now().strftime("%m/%d/%Y").to_s + DateTime.now().strftime(" à %I:%M%p").to_s)
    end
    @furlough.save
    role = Role.find(current_user.role_id)
    @journal = Journal.new
    @journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à approuvé un congé á partir de #{@furlough.start} jusqu'a #{@furlough.end} - loger le : #{Time.now}"
    @journal.the_model = 'furlough'
    @journal.the_model_id = @furlough.id
    @journal.user_id = current_user.id
    @journal.status = "Approuvé"
    @journal.save
    FurloughMailer.with(furlough: @furlough).approuve_furlough_email.deliver_later
    redirect_to furloughs_path
  end

  def valide_fc
    @furlough.update(status: "Approuvé", color: "green")
    role = Role.find(current_user.role_id)
    if @furlough.furlough_type.code == "CPA"
      bank = Bank.find_by(user_id: @furlough.user_id)
      furlough_duration = Furlough.get_furlough_duration(@furlough.start, @furlough.hour_start, @furlough.end, @furlough.hour_end)
      furlough_balance = bank.balance_furlough
      balance = furlough_balance - furlough_duration
      bank.update(balance_furlough: balance)
    elsif @furlough.furlough_type.code == "CRHS"
      @furlough.update(status: "Récupéré", color: "blue")
      user_furlough = User.find(@furlough.user_id)
      specification = Furlough.get_furlough_specification(@furlough, user_furlough)
      AdditionalHour.update_etat_additional_hours(specification, @furlough)
    end
    @journal = Journal.new
    @journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à approuvé un congé á partir de #{@furlough.start} jusqu'a #{@furlough.end} - loger le : #{Time.now}"
    @journal.the_model = 'furlough'
    @journal.the_model_id = @furlough.id
    @journal.user_id = current_user.id
    @journal.status = "Approuvé"
    @journal.save
    FurloughMailer.with(furlough: @furlough).approuve_furlough_email.deliver_later
    redirect_to furloughs_path
  end

  def pre_refuse

  end

  def refuse
    @furlough.update(furlough_refus_params)
 
    @furlough.update(status: "Refusé", color: "red")
    if @furlough.furlough_type.code == "CPA"
      bank = Bank.find_by(user_id: @furlough.user_id)
      furlough_duration = Furlough.get_furlough_duration(@furlough.start, @furlough.hour_start, @furlough.end, @furlough.hour_end)
      furlough_balance = bank.balance_furlough
      balance = furlough_balance + furlough_duration
      bank.update(balance_furlough: balance)
    end

    @furlough.save
    role = Role.find(current_user.role_id)
    @journal = Journal.new
    @journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à refusé un congé á partir de #{@furlough.start} jusqu'a #{@furlough.end} - loger le : #{Time.now}"
    @journal.the_model = 'furlough'
    @journal.the_model_id = @furlough.id
    @journal.user_id = current_user.id
    @journal.status = "Refusé"
    @journal.save
    FurloughMailer.with(furlough: @furlough).refuse_furlough_email.deliver_later
    redirect_to furloughs_path
  end

  def pre_cancel

  end

  def cancel 
    @furlough.update(furlough_cancel_params)
    @furlough.update(status: "Annulé", color: "black")
    if @furlough.furlough_type.code == "CPA"
      bank = Bank.find_by(user_id: @furlough.user_id)
      furlough_duration = Furlough.get_furlough_duration(@furlough.start, @furlough.hour_start, @furlough.end, @furlough.hour_end)
      furlough_balance = bank.balance_furlough
      balance = furlough_balance + furlough_duration
      bank.update(balance_furlough: balance)
    end

    @furlough.save
    role = Role.find(current_user.role_id)
    @journal = Journal.new
    @journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à annulé un congé á partir de #{@furlough.start} jusqu'a #{@furlough.end} - loger le : #{Time.now}"
    @journal.the_model = 'furlough'
    @journal.the_model_id = @furlough.id
    @journal.user_id = current_user.id
    @journal.status = "Cancel"
    @journal.save
    FurloughMailer.with(furlough: @furlough).cancel_furlough_email.deliver_later
    redirect_to furloughs_path
  
  end

  def soumettre
    if @furlough.furlough_type.code == "CPA"
      @furlough.update(status: "Soumis", color: "blue")
      bank = Bank.find_by(user_id: @furlough.user_id)
      furlough_duration = Furlough.get_furlough_duration(@furlough.start, @furlough.hour_start, @furlough.end, @furlough.hour_end)
      furlough_balance = bank.balance_furlough
      balance = furlough_balance - furlough_duration
      bank.update(balance_furlough: balance)
    elsif 
      @furlough.update(status: "Soumis", color: "blue")
    elsif @furlough.furlough_type.code == "CRHS"
      @furlough.update(status: "Récupéré", color: "blue")
      user_furlough = User.find(@furlough.user_id)
      specification = Furlough.get_furlough_specification(@furlough, user_furlough)
      AdditionalHour.update_etat_additional_hours(specification, @furlough)
    end
    @furlough.save
    FurloughMailer.with(furlough: @furlough).new_furlough_email.deliver_later
    role = Role.find(current_user.role_id)
    @journal = Journal.new
    @journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à soumis un congé á partir de #{@furlough.start} jusqu'a #{@furlough.end} - loger le : #{Time.now}"
    @journal.the_model = 'furlough'
    @journal.the_model_id = @furlough.id
    @journal.user_id = current_user.id
    @journal.status = "Soumis"
    @journal.save
    if ['Super Admin', 'Rh'].include? current_user.role.title
      if @furlough.user_id == current_user.id
        redirect_to furloughs_administration_path
      else
        redirect_to furloughs_path  
      end
    else 
      redirect_to furloughs_path
    end
  end

  def pre_stop
  end

  def stop
    user_furlough = User.find(@furlough.user_id)
    puts "---------------"
    puts user_furlough.is_active
    if user_furlough.is_active == false
      user_furlough.is_active = true 
      user_furlough.actif!
      user_furlough.save
    end

    if @furlough.furlough_type.code == "CPA"
      bank = Bank.find_by(user_id: @furlough.user_id)
      first_furlough_duration = Furlough.get_furlough_duration(@furlough.start, @furlough.hour_start, @furlough.end, @furlough.hour_end)
      last_furlough_duration = Furlough.get_furlough_duration(@furlough.start, @furlough.hour_start, furlough_stop_params[:stop_date], furlough_stop_params[:hour_stop])
      duration_to_add = first_furlough_duration - last_furlough_duration
      furlough_balance = bank.balance_furlough
      balance = furlough_balance + duration_to_add
      bank.update(balance_furlough: balance)
    end
    @furlough.update(end: furlough_stop_params[:stop_date], hour_end: furlough_stop_params[:hour_stop], stop_comment: furlough_stop_params[:stop_comment], status: "Arrêté")
    FurloughMailer.with(furlough: @furlough).stop_furlough_email.deliver_later
    role = Role.find(current_user.role_id)
    @journal = Journal.new
    @journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à arrêter le congé avec la référence #{@furlough.reference_furlough} pour le collaborateur #{@furlough.user.first_name} #{@furlough.user.last_name} - loger le : #{Time.now}"
    @journal.the_model = 'furlough'
    @journal.the_model_id = @furlough.id
    @journal.user_id = current_user.id
    @journal.status = "Arrét"
    @journal.save
   
    redirect_to furloughs_path
    
  end

  def pre_discontinuity
  end

  def discontinuity
    if furlough_params[:start].to_datetime.strftime('%Y%m%d').to_i > @furlough.child_date.to_datetime.strftime('%Y%m%d').to_i
      end_date_discontinuity = @furlough.child_date.send(:+, 30.day)
      if furlough_params[:end].to_date > end_date_discontinuity
        duration = 0.0
        Furlough.where(parent_id: @furlough.id).each do |f|
          duration += Furlough.get_furlough_duration(f.start, f.hour_start, f.end, f.hour_end)
        end
        duration += Furlough.get_furlough_duration(@furlough.start, @furlough.hour_start, @furlough.end, @furlough.hour_end)
        message_1 = "vous avez consomé #{duration} jour(s) de ce congé il vous reste #{15 - duration} jour(s) à consomé avant le #{end_date_discontinuity.to_s}"
        if ['Super Admin', 'Rh'].include? current_user.role.title
          if @furlough.user_id.present? && @furlough.user_id != current_user.id
            redirect_to furloughs_path, info: ["Votre demmande de discontinuté n'a pas été traité", message_1]
          else
            redirect_to furloughs_administration_path, info: ["Votre demmande de discontinuté n'a pas été traité", message_1]
          end
        else
          redirect_to furloughs_path, info: ["Votre demmande de discontinuté n'a pas été traité", message_1]
        end
      else
        duration = 0.0
        Furlough.where(parent_id: @furlough.id).each do |f|
          duration += Furlough.get_furlough_duration(f.start, f.hour_start, f.end, f.hour_end)
        end
        parent_furlough_duration = Furlough.get_furlough_duration(@furlough.start, @furlough.hour_start, @furlough.end, @furlough.hour_end)
        last_furlough_duration = Furlough.get_furlough_duration(furlough_params[:start], furlough_params[:hour_start], furlough_params[:end], furlough_params[:hour_end])
        if (duration + parent_furlough_duration + last_furlough_duration) > @furlough.furlough_type.max_duration
          if ['Super Admin', 'Rh'].include? current_user.role.title
            if @furlough.user_id.present? && @furlough.user_id != current_user.id
              redirect_to furloughs_path, info: ["Votre demmande de discontinuté n'a pas été traité", message_1]
            else
              redirect_to furloughs_administration_path, info: ["Votre demmande de discontinuté n'a pas été traité", message_1]
            end
          else
            redirect_to furloughs_path, info: ["Votre demmande de discontinuté n'a pas été traité", message_1]
          end
        else
          if ['Super Admin', 'Rh'].include? current_user.role.title
            if @furlough.user_id.present? && @furlough.user_id != current_user.id
              furlough = Furlough.new(furlough_params)
              furlough.furlough_type_id = @furlough.furlough_type_id
              furlough.status = "En cours"
              furlough.user_id = @furlough.user_id
              furlough.parent_id = @furlough.id
              furlough.save
              redirect_to furloughs_path, success: "Votre demmande de discontinuté à été bien traité"
            else
              furlough = Furlough.new(furlough_params)
              furlough.furlough_type_id = @furlough.furlough_type_id
              furlough.status = "Nouveau"
              furlough.user_id = current_user.id
              furlough.parent_id = @furlough.id
              furlough.save
              redirect_to furloughs_administration_path, success: "Votre demmande de discontinuté à été bien traité"
            end
          else
            furlough = Furlough.new(furlough_params)
            furlough.furlough_type_id = @furlough.furlough_type_id
            furlough.status = "Nouveau"
            furlough.user_id = current_user.id
            furlough.parent_id = @furlough.id
            furlough.save
            redirect_to furloughs_path, success: "Votre demmande de discontinuté à été bien traité"
          end
        end
      end  
    else
      redirect_to furloughs_path, info: ["La date de début de congé ne dois pas être inferieure que la date de naissance du fils"]
    end
  end

  def pre_regularized
    @balance_furlough_day = Bank.find_by(user_id: @furlough.user_id).balance_furlough
    @balance_furlough_day_réel = Furlough.get_balance_current_month(current_user.id)
    @balance_d = (@balance_furlough_day + @balance_furlough_day_réel).round(2)
    @furlough_duration = Furlough.get_furlough_duration(@furlough.start, @furlough.hour_start, @furlough.end, @furlough.hour_end) 
   # if @furlough.start < DateTime.now()
      @furlough_duration_consumed = Furlough.get_furlough_duration(@furlough.start, @furlough.hour_start, DateTime.now(), '8:00')
   # end
  end

  def regularized
    furlough = Furlough.new(furlough_regularized_params)
    
    furlough.user_id = @furlough.user_id
    furlough.status = "Approuvé"
    furlough.furlough_regular_id = @furlough.id
    furlough.start = @furlough.start
    furlough.hour_start = @furlough.hour_start
    user_furlough = User.find(@furlough.user_id)
    furlough.signature_collab = "Approuvé par " + furlough.user.first_name + " " + furlough.user.last_name + " _" + " Le " + DateTime.now().strftime("%m/%d/%Y").to_s + DateTime.now().strftime(" à %I:%M%p").to_s

    if !user_furlough.line_manager_id.blank?
      g_h = User.find(user_furlough.line_manager_id) 
      furlough.signature_g_h = "Approuvé par " + g_h.first_name + " " + g_h.last_name + " _" + " Le " + DateTime.now().strftime("%m/%d/%Y").to_s + DateTime.now().strftime(" à %I:%M%p").to_s
      furlough.signature_g_f = "Approuvé par " + current_user.first_name + " " + current_user.last_name + " _" + " Le " + DateTime.now().strftime("%m/%d/%Y").to_s + DateTime.now().strftime(" à %I:%M%p").to_s
    else 
      furlough.signature_g_h = " "
      furlough.signature_g_f = "Approuvé par " + current_user.first_name + " " + current_user.last_name + " _" + " Le " + DateTime.now().strftime("%m/%d/%Y").to_s + DateTime.now().strftime(" à %I:%M%p").to_s
    end   
    furlough.save

    furlough_type = FurloughType.find(furlough_regularized_params[:furlough_type_id])
    if furlough_type.code == "CPAR"
      bank = Bank.find_by(user_id: @furlough.user_id)
      furlough_duration = Furlough.get_furlough_duration(furlough_regularized_params[:start], furlough_regularized_params[:hour_start], furlough_regularized_params[:end], furlough_regularized_params[:hour_end])
      furlough_balance = bank.balance_furlough
      balance = furlough_balance - furlough_duration
      bank.update(balance_furlough: balance)
    end
    @furlough.update(furlough_regular_id: furlough.id, status: 'Régularisé')
    role = Role.find(current_user.role_id)
    @journal = Journal.new
    @journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à régularisé le congé avec la référence #{@furlough.reference_furlough}  - loger le : #{Time.now}"
    @journal.the_model = 'furlough'
    @journal.the_model_id = furlough.id
    @journal.user_id = current_user.id
    @journal.status = "Régularisé"
    @journal.save

    @journal = Journal.new
    @journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à approuvé le congé avec la référence #{furlough.reference_furlough}  - loger le : #{Time.now}"
    @journal.the_model = 'furlough'
    @journal.the_model_id = @furlough.id
    @journal.user_id = current_user.id
    @journal.status = "Approuvé"
    @journal.save
    redirect_to furloughs_path, success: "Votre demmande de régulérisation à été bien traité"
  end

  def pre_consum

  end

  def consum 
    @additional_hour.update(furlough_cancel_params)

    #role = Role.find(current_user.role_id)
    #@journal = Journal.new
    #@journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à annulé un congé á partir de #{@furlough.start} jusqu'a #{@furlough.end} - loger le : #{Time.now}"
    #@journal.the_model = 'furlough'
    #@journal.the_model_id = @furlough.id
    #@journal.user_id = current_user.id
    #@journal.status = "Cancel"
    #@journal.save
    #FurloughMailer.with(furlough: @furlough).cancel_furlough_email.deliver_later
    redirect_to additional_hours_path
  
  end

  # When the current user is a collaborator
  # This method return number of days taken in this furlough
  def durations_taken
    start_date = DateTime.parse(params[:start])
    end_date = DateTime.parse(params[:end])
    hour_start = params[:hour_start]
    hour_end = params[:hour_end]
    furlough_duration = Furlough.get_furlough_duration(start_date, hour_start, end_date, hour_end)
    render :json => furlough_duration
  end

  def duration_hour_taken
    start_date = DateTime.parse(params[:start])
    end_date = DateTime.parse(params[:end])
    hour_start = params[:hour_start]
    hour_end = params[:hour_end]
    user_id = params[:user_id]
   
    results = HoursValidity.get_valid_hours_2(user_id, start_date, hour_start, end_date, hour_end)
  
    furlough__hour_duration = Furlough.get_hour_furlough_duration(start_date, hour_start, end_date, hour_end)
    render :json => {
      :furlough__hour_duration => furlough__hour_duration,
      :results => results
    }
  end
    
  def find_furlough_type
    @furlough_type = FurloughType.find(params[:id])
    render :json => @furlough_type
  end

  def find_fonctional_manager_id
    first_name = params[:name].split.first
    last_name = params[:name].split.last
    fonctional_manager = FonctionalManager.find_by(first_name: first_name, last_name: last_name)
    render :json => fonctional_manager.id
  end

  def find_user_id
    first_name = params[:name].split.first
    last_name = params[:name].split.last
    user = User.find_by(first_name: first_name, last_name: last_name)
    render :json => user.id
  end

  def find_line_manager_id
    first_name = params[:name].split.first
    last_name = params[:name].split.last
    user = User.find_by(first_name: first_name, last_name: last_name)
    render :json => user.id
  end

  def full_name_fonctional
    fonctional_manager = FonctionalManager.find(current_user.fonctionnal_manager_id)
    
    if fonctional_manager
      full_name = fonctional_manager.first_name + " " + fonctional_manager.last_name
    else
      full_name = ""
    end

    render :json => full_name
  end

  def to_print
    respond_to do |format|
      furlough_duration = Furlough.get_furlough_duration(@furlough.start, @furlough.hour_start, @furlough.end, @furlough.hour_end)
      format.pdf do
        pdf = FurloughPdf.new(@furlough, furlough_duration)
        send_data pdf.render, filename: 'Demande_de_congé.pdf', type: 'application/pdf', disposition: "inline"
      end
    end
  end

  #Not used
  def take_start_date()
    @furlough_type = FurloughType.find(params[:type_furlough])
    setting = Setting.find(1)

    if @furlough_type.informing_before
      days = Furlough.get_furlough_date(Date.today, params[:start_date].to_date)

        if days.count * 24 < setting.informing_before_duration
          start_d = Furlough.take_start(dayToCheck)
        else
          start_d = params[:start_date].to_date
        end
    else
      start_d = params[:start_date].to_date
    end

    render :json => start_d
  end

  private
    def set_furlough
      @furlough = Furlough.find(params[:id])
    end

    def furlough_params
      params.require(:furlough).permit(:title, :start, :end, :description, :user_id, :furlough_type_id, :documment, :hour_start, :hour_end, :child_date)
    end

    def u_furlough_attached_params
      params.require(:furlough).permit(:documment)
    end

    def furlough_self_params
      params.require(:furlough).permit(:title, :start, :end, :furlough_type_id, :documment, :hour_start, :hour_end, :child_date)
    end

    def furlough_refus_params
      params.require(:furlough).permit(:refuse_comment, :refus_date)
    end

    def furlough_stop_params
      params.require(:furlough).permit(:stop_comment, :stop_date, :hour_stop)
    end

    def furlough_cancel_params
      params.require(:furlough).permit(:cancel_comment, :cancel_date)
    end

    def furlough_regularized_params
      params.require(:furlough).permit(:furlough_type_id, :start, :hour_start, :end, :hour_end)
    end
end
