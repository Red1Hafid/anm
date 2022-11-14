class AdditionalHoursController < ApplicationController
    before_action :authenticate_user!
    before_action :set_additional_hour, only: [:show, :edit, :update, :destroy, :soumettre_additional_hour]
    load_and_authorize_resource
  
    def index
      if ["Super Admin", "Rh"].include? current_user.role.title 
        if params[:additional_hour_type].present?
          additional_hour_type_id = AdditionalHourType.find_by(code: params[:additional_hour_type])
          @additional_hours = AdditionalHour.where(additional_hour_type_id: additional_hour_type_id).order(created_at: :desc)
        else
          @additional_hours = AdditionalHour.all.order(created_at: :desc)
        end 

        users_not_actif_ids = User.where(is_active: false).pluck(:id)
        @users = User.all.where.not(id: users_not_actif_ids)
      else
        if params[:additional_hour_type].present?
          additional_hour_type_id = AdditionalHourType.find_by(code: params[:additional_hour_type])
          @additional_hours = AdditionalHour.where(additional_hour_type_id: additional_hour_type_id).where(user_id: current_user).where.not(status: 1).order(created_at: :desc)
          if params[:additional_hour_type] == 'HSJFT'
            @balance_open_additional_hour_off_days = Bank.find_by(user_id: current_user).balance_open_additional_hour_off_days
          end
        else
          @additional_hours = AdditionalHour.all.where(user_id: current_user).where.not(status: 1).order(created_at: :desc)
          @balance_open_additional_hour_off_days = Bank.find_by(user_id: current_user).balance_open_additional_hour_off_days 
        end  
      end
      @offs_of_form = AdditionalHoursHelper.get_offs_of_form
      @setting = Setting.find(1)
    end

    def additional_hours_administration
      if params[:additional_hour_type].present?
        additional_hour_type_id = AdditionalHourType.find_by(code: params[:additional_hour_type])
        @additional_hours = AdditionalHour.where(additional_hour_type_id: additional_hour_type_id).where(user_id: current_user).where.not(status: 1).order(created_at: :desc)
        if params[:additional_hour_type] == 'HSJFT'
          @balance_open_additional_hour_off_days = Bank.find_by(user_id: current_user).balance_open_additional_hour_off_days
        end
      else
        @additional_hours = AdditionalHour.all.where(user_id: current_user).where.not(status: 1).order(created_at: :desc)
        @balance_open_additional_hour_off_days = Bank.find_by(user_id: current_user).balance_open_additional_hour_off_days 
      end  
      @setting = Setting.find(1)
    end
  
    def show
    end
  
    def new
      @additional_hour = AdditionalHour.new
    end
  
    def edit
      users_not_actif_ids = User.where(is_active: false).pluck(:id)
      @users = User.all.where.not(id: users_not_actif_ids)
    end
  
    def create
      @additional_hour = AdditionalHour.new(additional_hour_params)
      @additional_hour.additional_hour_date = Date.today
      exist_additional_hour = AdditionalHour.find_by(period: additional_hour_params[:period], user_id: additional_hour_params[:user_id], additional_hour_type_id: additional_hour_params[:additional_hour_type_id])
      if !exist_additional_hour.present?
         @additional_hour.stay_hours = @additional_hour.total_additional_hour_in_week
         @additional_hour.save

        if @additional_hour.additional_hour_type.code == 'HSJO'
          bank = Bank.find_by(user_id: additional_hour_params[:user_id])
          total_additional_hour = bank.balance_open_additional_hour + @additional_hour.total_additional_hour_in_week
          bank.update(balance_open_additional_hour: total_additional_hour)  
        else
          bank = Bank.find_by(user_id: additional_hour_params[:user_id])
          total_additional_hour = bank.balance_open_additional_hour_off_days + @additional_hour.total_additional_hour_in_week
          bank.update(balance_open_additional_hour_off_days: total_additional_hour)  
        end

        #role = Role.find(current_user.role_id)
        #@journal = Journal.new
        #@journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à crée des actions d'arrêt - loger le : #{Time.now}"
        #@journal.the_model = 'Action'
        #@journal.the_model_id = @stop_action.id
        #@journal.user_id = current_user.id
        #@journal.status = "Created"
        #@journal.save

        redirect_to additional_hours_path, success: "la demmande a été bien crée."
      else
        redirect_to additional_hours_path, danger: "la période est déja traité"
      end
      
    end
  
    def update 
      if @additional_hour.additional_hour_type.code == 'HSJO'
        bank = Bank.find_by(user_id: @additional_hour.user_id)
        total_additional_hour = bank.balance_open_additional_hour - @additional_hour.total_additional_hour_in_week
        bank.update(balance_open_additional_hour: total_additional_hour)
        @additional_hour.update(additional_hour_params)
        total_additional_hour_after_update = bank.balance_open_additional_hour + @additional_hour.total_additional_hour_in_week
        bank.update(balance_open_additional_hour: total_additional_hour_after_update) 
      else
        bank = Bank.find_by(user_id: @additional_hour.user_id)
        total_additional_hour = bank.balance_open_additional_hour_off_days - @additional_hour.total_additional_hour_in_week
        bank.update(balance_open_additional_hour_off_days: total_additional_hour)
        @additional_hour.update(additional_hour_params)
        total_additional_hour_after_update = bank.balance_open_additional_hour_off_days + @additional_hour.total_additional_hour_in_week
        bank.update(balance_open_additional_hour_off_days: total_additional_hour_after_update) 
      end

      #role = Role.find(current_user.role_id)
      #@journal = Journal.new
      #@journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à modifié une action - loger le : #{Time.now}"
      #@journal.the_model = 'Action'
      #@journal.the_model_id = @stop_action.id
      #@journal.user_id = current_user.id
      #@journal.status = "Updated"
      #@journal.save
      redirect_to additional_hours_path, notice: "la demmande a été bien modifié."
    end

    def soumettre_additional_hour
      @additional_hour.aprouved!
      @additional_hour.save

      if @additional_hour.additional_hour_type.code == 'HSJO'
        bank = Bank.find_by(user_id: @additional_hour.user_id)
        balance_furlough_after_add_total_additional_hour = bank.balance_furlough + (@additional_hour.total_additional_hour_in_week.to_f / 8)
        balance_open_additional_hour = bank.balance_open_additional_hour - @additional_hour.total_additional_hour_in_week
        bank.update(balance_furlough: balance_furlough_after_add_total_additional_hour, balance_open_additional_hour: balance_open_additional_hour) 
      end
      redirect_to additional_hours_path, notice: "la demmande a été bien soumis."
    end
  
    def destroy
      if @additional_hour.additional_hour_type.code == 'HSJO'
        bank = Bank.find_by(user_id: @additional_hour.user_id)
        total_additional_hour = bank.balance_open_additional_hour - @additional_hour.total_additional_hour_in_week
        bank.update(balance_open_additional_hour: total_additional_hour)
      else
        bank = Bank.find_by(user_id: @additional_hour.user_id)
        total_additional_hour = bank.balance_open_additional_hour_off_days - @additional_hour.total_additional_hour_in_week
        bank.update(balance_open_additional_hour_off_days: total_additional_hour) 
      end

      @additional_hour.destroy
      #role = Role.find(current_user.role_id)
      #@journal = Journal.new
      #@journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à supprimé une action - loger le : #{Time.now}"
      #@journal.the_model = 'Action'
      #@journal.the_model_id = @stop_action.id
      #@journal.user_id = current_user.id
      #@journal.status = "Deleted"
      #@journal.save
      redirect_to additional_hours_path
    end

    def import
      AdditionalHour.import(params[:file])
      #role = Role.find(current_user.role_id)
      #@journal = Journal.new
      #@journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à importé des actions d'arrêt - loger le : #{Time.now}"
      #@journal.the_model = 'Action'
      #@journal.user_id = current_user.id
      #@journal.status = "Imported"
      #@journal.save
      redirect_to additional_hours_path, notice: "la list des actions a été bien importé."
    end

    def get_days_of_input_form

      period = params[:period]
      start_period = period.split(/ - */).first.to_date
      end_period = period.split(/ - */).last.to_date

      off_days = Off.off_between(start_period, end_period)

      off_days_not_include_week_day = []
      if !off_days.empty?
        off_days.each do |off|
          off_days_not_include_week_day << (off.start.to_date..off.end.to_date).to_a.select {|k| [1,2,3,4,5,6].include?(k.wday)} 
        end
      end

      days_of_input_form = []
      off_days_not_include_week_day.each do |day|
        days_of_input_form += day
      end
      days_of_input_form.push(end_period)

      render :json => days_of_input_form 
    end   

    def get_valid_hours(d1, h1, d2, h2)
      results = HoursValidity.get_valid_hours_2(current_user.id, d1, h1, d2, h2)
      render :json => results 
    end

    def pre_export_additional_hours
      @additional_hours_periods = AdditionalHour.all.pluck(:period)
    end
  
    def export_additional_hours
      @additional_hours = AdditionalHour.where(nil)
  
      if params[:period_additional_hour].present?
        @additional_hours = @additional_hours.filter_by_period(params[:period_additional_hour]) 
      end
  
      if params[:type_additional_hours].present?
        case params[:type_additional_hours]
        when "Tous"
          code_additional_hours = ['HSJFT','HSJO']
          ids_additional_hour_type = AdditionalHourType.where(code: code_additional_hours)
          @additional_hours = @additional_hours.filter_by_additional_hours_type_ids(ids_additional_hour_type) 
        when 'HSJFT'
          code_additional_hour = 'HSJFT'
          id_additional_hour = AdditionalHourType.find_by(code: code_additional_hour)
          @additional_hours = @additional_hours.filter_by_additional_hour_type_id(id_additional_hour) 
        when 'HSJO'
          code_additional_hour = 'HSJO'
          id_additional_hour = AdditionalHourType.find_by(code: code_additional_hour)
          @additional_hours = @additional_hours.filter_by_additional_hours_type_id(id_additional_hour) 
        end
      end
  
      puts "---------"
      puts @additional_hours
      
  
      filename = "Rapport-heures-sup-" + Date.today.to_s + ".xlsx" 
      respond_to do |format|
        format.xlsx { headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" }
      end
  
    end
  
    private

    def set_additional_hour
      @additional_hour = AdditionalHour.find(params[:id])
    end

    def additional_hour_params
      params.require(:additional_hour).permit(:additional_hour_date, :period, :total_additional_hour_in_week, :comment, :user_id, :additional_hour_type_id, :monday_quantity, :tuesday_quantity, :wednesday_quantity, :thursday_quantity, :friday_quantity, :saturday_quantity, :sunday_quantity)
    end
end
  
