class AutorizationsController < ApplicationController
  before_action :set_autorization, only: %i[ show edit update destroy soumettre_autorization validate_autorization pre_refus refus_autorization to_print_authorisation pre_recovered recovered ]

  # GET /autorizations or /autorizations.json
  def index
    if ["Super Admin", "Rh"].include? current_user.role.title 
      @autorizations = Autorization.where.not(status: 1)
    else
      if !current_user.manager_titles.nil?
        if current_user.manager_titles.include? "Gestionnaire hiérarchique"
          user_ids = User.where(line_manager_id: current_user.id).pluck(:id)
          @autorizations = Autorization.where(user_id: user_ids)
        else
          @autorizations = Autorization.where(user_id: current_user.id)
        end 
      else
        @autorizations = Autorization.where(user_id: current_user.id)
      end
    end

      @setting = Setting.find(1)
      users_not_actif_ids = User.where(is_active: false).pluck(:id)
      @users = User.where.not(id: users_not_actif_ids)
  end

  def authorizations_administration 
    @autorizations = Autorization.where(user_id: current_user.id)
     
    @setting = Setting.find(1)
  end

  # GET /autorizations/1 or /autorizations/1.json
  def show
  end

  # GET /autorizations/new
  def new
    @autorization = Autorization.new
  end

  # GET /autorizations/1/edit
  def edit

  end

  # POST /autorizations or /autorizations.json
  def create
    @autorization = Autorization.new(autorization_params) 
    authorization_duration = Autorization.get_hour_authorization_duration(@autorization.date, @autorization.start_hour, @autorization.end_hour).to_f
    @autorization.stay_hour = authorization_duration
    @autorization.time_taken = authorization_duration
    @autorization.demand_date = DateTime.now.strftime("%d/%m/%Y %H:%M")
    if ["Super Admin", "Rh"].include? current_user.role.title 
      if @autorization.user_id == current_user.id
        @autorization.encours!
        if @autorization.save
          redirect_to authorizations_administration_path, notice: "Autorisation was successfully created." 
        end
      else
        @autorization.encours!
        if @autorization.save
          redirect_to autorizations_path, notice: "Autorisation was successfully created." 
        end
      end
    else
      if !current_user.manager_titles.nil?
        if current_user.manager_titles.include? "Gestionnaire hiérarchique"
          if @autorization.save
            redirect_to authorizations_administration_path, notice: "Autorisation was successfully created." 
          end
        else
          if @autorization.save
            redirect_to autorizations_path, notice: "Autorisation was successfully created." 
          end
        end
      else
        if @autorization.save
          redirect_to autorizations_path, notice: "Autorisation was successfully created." 
        end
      end
    end
  end

  # PATCH/PUT /autorizations/1 or /autorizations/1.json
  def update
    authorization_duration = Autorization.get_hour_authorization_duration(autorization_params[:date], autorization_params[:start_hour], autorization_params[:end_hour]).to_f
    if ["Super Admin", "Rh"].include? current_user.role.title 
      if @autorization.user_id == current_user.id
        if @autorization.update(autorization_params.merge(stay_hour: authorization_duration, time_taken: authorization_duration))
          redirect_to authorizations_administration_path, notice: "Autorisation was successfully updated." 
        end
      else
        if @autorization.update(autorization_params.merge(stay_hour: authorization_duration, time_taken: authorization_duration))
          redirect_to autorizations_path, notice: "Autorisation was successfully updated." 
        end
      end
     
    else
      if !current_user.manager_titles.nil?
        if current_user.manager_titles.include? "Gestionnaire hiérarchique"
          if @autorization.update(autorization_params.merge(stay_hour: authorization_duration, time_taken: authorization_duration))
            redirect_to authorizations_administration_path, notice: "Autorisation was successfully updated." 
          end
        else
          if @autorization.update(autorization_paramsn.merge(stay_hour: authorization_duration, time_taken: authorization_duration))
            redirect_to autorizations_path, notice: "Autorisation was successfully updated." 
          end
        end
      else
        if @autorization.update(autorization_params.merge(stay_hour: authorization_duration, time_taken: authorization_duration))
          redirect_to autorizations_path, notice: "Autorisation was successfully updated." 
        end
      end
    end
  end

  def soumettre_autorization
    @autorization.soumis!
    @autorization.signature_collab = "Approuvé par " + current_user.first_name + " " + current_user.last_name + " _" + " Le " + DateTime.now().strftime("%m/%d/%Y").to_s + DateTime.now().strftime(" à %I:%M%p").to_s
    @autorization.submit_date = DateTime.now.strftime("%d/%m/%Y %H:%M")
    if @autorization.save
      redirect_to autorizations_path, notice: "Autorization was successfully submited." 
    end
  end

  def validate_autorization
    authorization_duration = Autorization.get_hour_authorization_duration(@autorization.date, @autorization.start_hour, @autorization.end_hour).to_f
    @autorization.aprouved!
    @autorization.validate_date = DateTime.now.strftime("%d/%m/%Y %H:%M")
    @autorization.is_ok = true if authorization_duration <= 2
    user_authorization = User.find(@autorization.user_id)
    if !user_authorization.line_manager_id.nil?
      g_h = User.find(user_authorization.line_manager_id)
    end
    
    if @autorization.signature_collab.nil?
      @autorization.signature_collab = "Approuvé par " + user_authorization.first_name + " " + user_authorization.last_name + " _" + " Le " + DateTime.now().strftime("%m/%d/%Y").to_s + DateTime.now().strftime(" à %I:%M%p").to_s
    end

    if g_h 
      @autorization.signature_g_h = "Approuvé par " + g_h.first_name + " " + g_h.last_name + " _" + " Le " + DateTime.now().strftime("%m/%d/%Y").to_s + DateTime.now().strftime(" à %I:%M%p").to_s
    else
      @autorization.signature_g_h = "  _" + "  "
    end

    if current_user.role.title == "Rh"
      @autorization.signature_g_f = "Approuvé par " + current_user.first_name + " " + current_user.last_name + " _" + " Le " + DateTime.now().strftime("%m/%d/%Y").to_s + DateTime.now().strftime(" à %I:%M%p").to_s
    else
      @autorization.signature_g_f = "  _" + "  "
    end

    if @autorization.save
      redirect_to autorizations_path, notice: "Autorization was successfully aprouved." 
    end
  end

  def pre_refus
  end

  def refus_autorization
    @autorization.refuse!
    @autorization.refus_date = DateTime.now.strftime("%d/%m/%Y %H:%M")
    @autorization.refus_motif = refused_params[:refus_motif]
    @autorization.is_ok = true
    if @autorization.save
      redirect_to autorizations_path, notice: "Autorization was successfully refused." 
    end
  end
  

  # DELETE /autorizations/1 or /autorizations/1.json
  def destroy
    @autorization.destroy

    respond_to do |format|
      format.html { redirect_to autorizations_url, notice: "Autorization was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def pre_recovered
  end

  def recovered
    @setting = Setting.find(1)
    bank = Bank.find_by(user_id: @autorization.user_id)
    volume = recorvred_params[:volume].to_f

    if @autorization.stay_hour >= volume
      if @autorization.recovery_method == "1"
        if volume <=  bank.balance_open_additional_hour_off_days
          bank.update(balance_open_additional_hour_off_days: bank.balance_open_additional_hour_off_days - volume)
          @autorization.update(stay_hour: @autorization.stay_hour - volume, history: @autorization.history.push(recorvred_params[:history_date].to_s + " recouvrement de " + volume.to_s + " h"))
          volume = 0.0
        else
          history_volume = 0.0
          volume -= bank.balance_open_additional_hour_off_days
          history_volume += bank.balance_open_additional_hour_off_days
          bank.update(balance_open_additional_hour_off_days: 0) 
          if volume > 0
            if (volume / @setting.day_work_hour) <= bank.balance_furlough 
              bank.update(balance_furlough: bank.balance_furlough - (volume / @setting.day_work_hour))
              history_volume += volume
              @autorization.update(stay_hour: @autorization.stay_hour - history_volume, history: @autorization.history.push(recorvred_params[:history_date].to_s + " recouvrement de " + history_volume.to_s + " h"))
            else
              history_volume += bank.balance_furlough * @setting.day_work_hour
              @autorization.update(stay_hour: @autorization.stay_hour - history_volume, history: @autorization.history.push(recorvred_params[:history_date].to_s + " recouvrement de " + history_volume.to_s + " h"))
              bank.update(balance_furlough: 0.0)
            end
          end
        end
      else
        @autorization.update(stay_hour: @autorization.stay_hour - volume, history: @autorization.history.push(recorvred_params[:history_date].to_s + " recouvrement de " + volume.to_s + " h"))
      end
      if @autorization.stay_hour > 0
        redirect_to autorizations_path, warning: "It remains " + @autorization.stay_hour.to_s + " that must be managed manually."
      else
        @autorization.update(is_ok: true)
        redirect_to autorizations_path, success: "Autorization was successfully processed."
      end
    else
      redirect_to autorizations_path, warning: "Invalid volume (" + volume.to_s + ")"
    end
  end

  def duration_hour_taken_of_authorization
    date = DateTime.parse(params[:date])
    hour_start = params[:start_hour]
    hour_end = params[:end_hour]
    user_id = params[:user_id]
   
    count_authorizations = Autorization.count_authorisations(date.month, user_id).count
  
    authorization__hour_duration = Autorization.get_hour_authorization_duration(date, hour_start, hour_end)
    render :json => {
      :authorization__hour_duration => authorization__hour_duration,
      :count_authorizations => count_authorizations
    }
  end

  def to_print_authorisation
    respond_to do |format|
      authorization_duration = Autorization.get_hour_authorization_duration(@autorization.date, @autorization.start_hour, @autorization.end_hour)
      format.pdf do
        pdf = AutorizationPdf.new(@autorization, authorization_duration)
        send_data pdf.render, filename: "Demande_d'authorisation.pdf", type: 'application/pdf', disposition: "inline"
      end
    end
  end

  def pre_export_authorizations
  
  end

  def export_authorizations
    @autorizations = Autorization.where(nil)
    if params[:date_authorization].present?
      if params[:oppeateur_date].present?
        case params[:oppeateur_date]
        when 'Supérieure que'
          @autorizations = @autorizations.filter_by_sup_date(params[:date_authorization]) 
        when 'Inférieure que'
          @autorizations = @autorizations.filter_by_inf_date(params[:date_authorization]) 
        when 'Égale'
          @autorizations = @autorizations.filter_by_egal_date(params[:date_authorization]) 
        end
      end
    end

    if params[:status_authorization].present?
      case params[:status_authorization]
      when "Tous"
        status = ['1','2', '3', '4', '5']
        @autorizations = @autorizations.filter_by_all_status(status) 
      when 'Enregisté'
        @autorizations = @autorizations.filter_by_status(1) 
      when 'En cours'
        status = 'encours'
        @autorizations = @autorizations.filter_by_status(2) 
      when 'Soumis'
        status = 'soumis'
        @autorizations = @autorizations.filter_by_status(3) 
      when 'Validé'
        status = 'aprouved'
        @autorizations = @autorizations.filter_by_status(4)  
      when 'Refusé'
        status = 'refuse'
        @autorizations = @autorizations.filter_by_status(5) 
      end
    end

    if params[:recovery_method].present?
      case params[:recovery_method]
      when "Tous"
        recovery_methods = ['0','1']
        @autorizations = @autorizations.filter_by_all_recovery_method(recovery_methods)
      when 'Répartition des heures sur les autres jours travaillés de la semaine'
        recovery_method = '0'
        @autorizations = @autorizations.filter_by_recovery_method(recovery_method) 
      when 'Retrancher de mon solde de congé'
        recovery_method = '1'
        @autorizations = @autorizations.filter_by_recovery_method(recovery_method) 
      end
    end
    
    filename = "Rapport-autorisations-" + Date.today.to_s + ".xlsx" 
    respond_to do |format|
      format.xlsx { headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_autorization
      @autorization = Autorization.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def autorization_params
      params.require(:autorization).permit(:date, :start_hour, :end_hour, :comment, :department, :function, :recovery_method, :user_id)
    end

    def recorvred_params
      params.require(:autorization).permit(:volume, :history_date)
    end

    def refused_params
      params.require(:autorization).permit(:refus_motif)
    end
end