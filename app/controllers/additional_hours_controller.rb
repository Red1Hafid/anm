class AdditionalHoursController < ApplicationController
    before_action :authenticate_user!
    before_action :set_additional_hour, only: [:show, :edit, :update, :destroy, :soumettre_additional_hour]
    before_action :set_role, only: %i[ create update destroy soumettre_additional_hour import ]
    load_and_authorize_resource
  
    def index
      @setting = Setting.find(1)
      @offs_of_form = AdditionalHoursHelper.get_offs_of_form 

      if ["Super Admin", "Rh"].include? current_user.role.title 
        if params[:additional_hour_type].present?
          additional_hour_type = AdditionalHourType.find_by(code: params[:additional_hour_type])
          @additional_hours = additional_hour_type.additional_hours.order(created_at: :desc)
        else
          @additional_hours = AdditionalHour.all.order(created_at: :desc)
        end 
        @users = User.where(is_active: true).where.not(role_id: 1)
      else
        if params[:additional_hour_type].present?
          additional_hour_type = AdditionalHourType.find_by(code: params[:additional_hour_type])
          @additional_hours = current_user.additional_hours.where(additional_hour_type_id: additional_hour_type).where.not(status: 1).order(created_at: :desc)
          @balance_open_additional_hour_off_days = current_user.bank.balance_open_additional_hour_off_days if params[:additional_hour_type] == 'HSJFT' 
        else
          @additional_hours = current_user.additional_hours.where.not(status: 1).order(created_at: :desc)
        end  
      end
    end

    def additional_hours_administration
      @setting = Setting.find(1)
      if params[:additional_hour_type].present?
        additional_hour_type = AdditionalHourType.find_by(code: params[:additional_hour_type])
        @additional_hours = current_user.additional_hours.where(additional_hour_type_id: additional_hour_type).where.not(status: 1).order(created_at: :desc)
        @balance_open_additional_hour_off_days = current_user.bank.balance_open_additional_hour_off_days if params[:additional_hour_type] == 'HSJFT' 
      else
        @additional_hours = current_user.additional_hours.where.not(status: 1).order(created_at: :desc)
      end  
    end
  
    def show
    end
  
    def new
      @additional_hour = AdditionalHour.new
    end
  
    def edit
      @users = User.where(is_active: true)
      @offs_of_form = AdditionalHoursHelper.get_offs_of_form 
    end
  
    def create
      exist_additional_hour = AdditionalHour.find_by(period: additional_hour_params[:period], user_id: additional_hour_params[:user_id], additional_hour_type_id: additional_hour_params[:additional_hour_type_id])
      
      if !exist_additional_hour.present?
        @additional_hour = AdditionalHour.new(additional_hour_params.merge(additional_hour_date: Date.today, stay_hours: additional_hour_params[:total_additional_hour_in_week])) 
        if @additional_hour.save
          Journal.create_journal(@role.title, current_user, "ajouté", "AdditionalHour", "une nouvelle entrée des h'eures sup de", @additional_hour.user.email, @additional_hour.id, "Created")
          redirect_to additional_hours_path, success: "la demande a été créer avec succés."
        else
          redirect_to additional_hours_path, danger: "#{@additional_hour.errors.full_messages}"
        end 
      else
        redirect_to additional_hours_path, danger: "la période est déja traité"
      end 
    end
  
    def update 
     if @additional_hour.update(additional_hour_params.merge(additional_hour_date: Date.today, stay_hours: additional_hour_params[:total_additional_hour_in_week]))
        Journal.create_journal(@role.title, current_user, "modifié", "AdditionalHour", "une entrée des h'eures sup de", @additional_hour.user.email, @additional_hour.id, "Updated")
        redirect_to additional_hours_path, success: "La demande a été modifer avec succés."
     else
        redirect_to additional_hours_path, danger:  "#{@additional_hour.errors.full_messages}"
     end
    end

    def destroy
      if @additional_hour.destroy
        Journal.create_journal(@role.title, current_user, "supprimé", "AdditionalHour", "une entrée des h'eures sup de", @additional_hour.user.email, @additional_hour.id, "Deleted")
        redirect_to additional_hours_path, success: "La demande a été supprimer avec succés."
      end 
    end

    def soumettre_additional_hour
      @additional_hour.aprouved!
      bank = Bank.find_by(user_id: @additional_hour.user_id)
      @setting = Setting.find(1)

      if @additional_hour.additional_hour_type.code == 'HSJO'
        bank.increment('balance_furlough', @additional_hour.total_additional_hour_in_week.to_f / @setting.day_work_hour).save
      else
        bank.increment('balance_open_additional_hour_off_days', @additional_hour.total_additional_hour_in_week).save
      end
      Journal.create_journal(@role.title, current_user, "validé", "AdditionalHour", "une entrée des heures sup de", @additional_hour.user.email, @additional_hour.id, "Validated")
      redirect_to additional_hours_path, success: "la demande a été valider avec succés"
    end

    def import
      AdditionalHour.import(params[:file])
      Journal.create_journal(@role.title, current_user, "importé", "AdditionalHour", "une list des h'eures sup", nil, nil, "Imported")
      redirect_to additional_hours_path, notice: "la list des heures sup a été importer avec succés."
    end

    def get_days_of_input_form
      start_period = params[:period].split(/ - */).first.to_date
      end_period = params[:period].split(/ - */).last.to_date

      off_days = Off.off_between(start_period, end_period)

      days_of_input_form = []
      if !off_days.empty?
        off_days.each do |off|
          days_of_input_form << (off.start.to_date..off.end.to_date).to_a.select {|k| [1,2,3,4,5,6].include?(k.wday)} 
        end
      end

      render :json => days_of_input_form.flatten.push(end_period)
    end   

    def get_valid_hours(d1, h1, d2, h2)
      results = HoursValidity.get_valid_hours_2(current_user.id, d1, h1, d2, h2)
      render :json => results 
    end

    def pre_export_additional_hours
      @additional_hours_periods = AdditionalHour.all.pluck(:period).uniq
    end
  
    def export_additional_hours
      @additional_hours = AdditionalHour.where(nil)
      @additional_hours = AdditionalHour.exported_data_filtred(@additional_hours, params)
      filename = "Rapport-heures-sup-" + Date.today.to_s + ".xlsx" 

      respond_to do |format|
        format.xlsx { headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" }
      end
    end
  
    private

    def set_additional_hour
      @additional_hour = AdditionalHour.find(params[:id])
    end

    def set_role
      @role = Role.find(current_user.role_id)
    end

    def additional_hour_params
      params.require(:additional_hour).permit(:period, :total_additional_hour_in_week, :comment, :user_id, :additional_hour_type_id, :monday_quantity, :tuesday_quantity, :wednesday_quantity, :thursday_quantity, :friday_quantity, :saturday_quantity, :sunday_quantity)
    end
end
  
