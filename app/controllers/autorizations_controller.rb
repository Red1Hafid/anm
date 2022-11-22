class AutorizationsController < ApplicationController
  before_action :set_autorization, only: %i[ show edit update destroy soumettre_autorization validate_autorization refuse_autorization to_print_authorisation pre_recovered recovered ]

  # GET /autorizations or /autorizations.json
  def index
    if ["Super Admin", "Rh"].include? current_user.role.title 
      @autorizations = Autorization.all.where.not(status: 1)
    else
      if !current_user.manager_titles.nil?
        if current_user.manager_titles.include? "Gestionnaire hiérarchique"
          user_ids = User.where(line_manager_id: current_user.id).pluck(:id)
          @autorizations = Autorization.all.where(user_id: user_ids)
        else
          @autorizations = Autorization.all.where(user_id: current_user.id)
        end 
      else
        @autorizations = Autorization.all.where(user_id: current_user.id)
      end
    end

      @setting = Setting.find(1)
      users_not_actif_ids = User.where(is_active: false).pluck(:id)
      @users = User.all.where.not(id: users_not_actif_ids)
  end

  def authorizations_administration 
    @autorizations = Autorization.where(user_id: current_user.id).where.not(status: 2)
     
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
    if ["Super Admin", "Rh"].include? current_user.role.title 
      if @autorization.user_id == current_user.id
        @autorization.stay_hour = authorization_duration
        if @autorization.save
          redirect_to authorizations_administration_path, notice: "Autorization was successfully created." 
        end
      else
        @autorization.encours!
        @autorization.stay_hour = authorization_duration
        if @autorization.save
          redirect_to autorizations_path, notice: "Autorization was successfully created." 
        end
      end
     
    else
      if !current_user.manager_titles.nil?
        if current_user.manager_titles.include? "Gestionnaire hiérarchique"
          @autorization.stay_hour = authorization_duration
          if @autorization.save
            redirect_to authorizations_administration_path, notice: "Autorization was successfully created." 
          end
        else
          @autorization.stay_hour = authorization_duration
          if @autorization.save
            redirect_to autorizations_path, notice: "Autorization was successfully created." 
          end
        end
      else
        @autorization.stay_hour = authorization_duration
        if @autorization.save
          redirect_to autorizations_path, notice: "Autorization was successfully created." 
        end
      end
    end
  end

  # PATCH/PUT /autorizations/1 or /autorizations/1.json
  def update
    if ["Super Admin", "Rh"].include? current_user.role.title 
      if @autorization.user_id == current_user.id
        if @autorization.update(autorization_params)
          redirect_to authorizations_administration_path, notice: "Autorization was successfully updated." 
        end
      else
        if @autorization.update(autorization_params)
          redirect_to autorizations_path, notice: "Autorization was successfully updated." 
        end
      end
     
    else
      if !current_user.manager_titles.nil?
        if current_user.manager_titles.include? "Gestionnaire hiérarchique"
          if @autorization.update(autorization_params)
            redirect_to authorizations_administration_path, notice: "Autorization was successfully updated." 
          end
        else
          if @autorization.update(autorization_params)
            redirect_to autorizations_path, notice: "Autorization was successfully updated." 
          end
        end
      else
        if @autorization.update(autorization_params)
          redirect_to autorizations_path, notice: "Autorization was successfully updated." 
        end
      end
    end
  end

  def soumettre_autorization
    @autorization.soumis!
    @autorization.signature_collab = "Approuvé par " + current_user.first_name + " " + current_user.last_name + " _" + " Le " + DateTime.now().strftime("%m/%d/%Y").to_s + DateTime.now().strftime(" à %I:%M%p").to_s
    if @autorization.save
      redirect_to autorizations_path, notice: "Autorization was successfully submited." 
    end
  end

  def validate_autorization
    @autorization.aprouved!
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

  def refuse_autorization
    @autorization.refuse!
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

  def recovered_second
    @setting = Setting.find(1)
    bank = Bank.find_by(user_id: @autorization.user_id)
    furlough_balance = (bank.balance_furlough * @setting.day_work_hour).round(2)
    additional_hours_balance = bank.balance_open_additional_hour_off_days
    hour_stayed = @autorization.stay_hour

    if additional_hours_balance > 0
      if additional_hours_balance > hour_stayed
        additional_hours_balance -= hour_stayed
        hour_stayed = 0
        bank.update(balance_open_additional_hour_off_days: additional_hours_balance)
        @autorization.update(stay_hour: 0)
        @autorization.update(is_ok: true)
      else
        hour_stayed -= additional_hours_balance
        bank.update(balance_open_additional_hour_off_days: 0)
        @autorization.update(stay_hour: hour_stayed)
      end
    end

    if (furlough_balance > 0) && (hour_stayed > 0)
      if furlough_balance > hour_stayed
        furlough_balance -= hour_stayed
        furlough_balance_d = (furlough_balance / @setting.day_work_hour)
        bank.update(balance_furlough: furlough_balance_d)
        @autorization.update(stay_hour: 0)
        @autorization.update(is_ok: true)
      else
        hour_stayed -= furlough_balance
        bank.update(balance_furlough: 0.0)
        @autorization.update(stay_hour: hour_stayed)
      end
    end
    
    if @autorization.stay_hour > 0
      redirect_to autorizations_path, warning: "It remains " + hour_stayed.to_s + " that must be managed manually."
    else
      redirect_to autorizations_path, success: "Autorization was successfully processed."
    end 
  end

  def recovered
    @setting = Setting.find(1)
    bank = Bank.find_by(user_id: @autorization.user_id)
    furlough_balance = (bank.balance_furlough * @setting.day_work_hour)
    additional_hours_balance = bank.balance_open_additional_hour_off_days
    hour_stayed = @autorization.stay_hour
    stay_hour = @autorization.stay_hour
    volume = recorvred_params[:volume].to_f
    
    if @autorization.recovery_method == "1"

      if hour_stayed >= volume

        if additional_hours_balance > 0
          if additional_hours_balance > volume
            additional_hours_balance -= volume
            hour_stayed -= volume
            volume = 0.0
            bank.update(balance_open_additional_hour_off_days: additional_hours_balance) 
            @autorization.update(stay_hour: hour_stayed)
          else
            hour_stayed -= additional_hours_balance
            volume -= additional_hours_balance
            bank.update(balance_open_additional_hour_off_days: 0)
            @autorization.update(stay_hour: hour_stayed)
          end
        end

        if (furlough_balance > 0) && (hour_stayed > 0)
          if furlough_balance > volume
            furlough_balance -= volume
            hour_stayed -= volume
            furlough_balance_d = (furlough_balance / @setting.day_work_hour)
            bank.update(balance_furlough: furlough_balance_d)
            @autorization.update(stay_hour: hour_stayed)
          else
            hour_stayed -= furlough_balance
            bank.update(balance_furlough: 0.0)
            @autorization.update(stay_hour: hour_stayed)
          end
        end
        
        if @autorization.stay_hour > 0
          stay_after_update = stay_hour - recorvred_params[:volume].to_f 
          debit_volume = stay_hour - stay_after_update
          history = recorvred_params[:history_date].to_s + " recouvrement de " + debit_volume.to_s + " h"
          @autorization.history.push(history)
          @autorization.save

          redirect_to autorizations_path, warning: "It remains " + hour_stayed.to_s + " that must be managed manually."
        else
          @autorization.update(is_ok: true)
          history = recorvred_params[:history_date].to_s + " recouvrement de " + volume.to_s + " h"
          @autorization.history.push(history)
          @autorization.save
     
          redirect_to autorizations_path, success: "Autorization was successfully processed."
        end 
      else
        redirect_to autorizations_path, warning: "Invalid volume (" + volume.to_s + ")"
      end
    else
      if hour_stayed >= volume
        hour_stayed -= volume
        @autorization.update(stay_hour: hour_stayed)
        if hour_stayed == 0.0
          @autorization.update(is_ok: true)
          redirect_to autorizations_path, success: "Autorization was successfully processed."
        else
          redirect_to autorizations_path, warning: "It remains " + hour_stayed.to_s
        end
      else
        redirect_to autorizations_path, warning: "Invalid volume (" + volume.to_s + ")"
      end
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

    puts "---------"
    puts @autorizations
    

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
end