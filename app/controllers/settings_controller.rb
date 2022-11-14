class SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_setting, only: [:edit, :update]
  load_and_authorize_resource

  def index
    @setting = Setting.first
  end

  def edit
  end

  def update
    params_updated = []
    if @setting.month_balance != setting_params[:month_balance].to_f
      params_updated.push("Gain en solde (mensuel) de #{@setting.month_balance} à #{setting_params[:month_balance].to_f}")
    end
    if @setting.day_work_hour != setting_params[:day_work_hour].to_i
      params_updated.push("Volume d'heures quotidien de #{@setting.day_work_hour} à #{setting_params[:day_work_hour].to_f}")
    end
    if @setting.informing_before_duration != setting_params[:informing_before_duration].to_i
      params_updated.push("Illigibilité de demande de congé de #{@setting.informing_before_duration} à #{setting_params[:informing_before_duration].to_f}")
    end
    if @setting.number_items_of_page != setting_params[:number_items_of_page].to_i
      params_updated.push("Nombre de ligne par page (pagination) de #{@setting.number_items_of_page} à #{setting_params[:number_items_of_page].to_f}")
    end
    @setting.update(setting_params)
    role = Role.find(current_user.role_id)
    @journal = Journal.new
    @journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à modifié les paramétres generales du calcule #{params_updated}  - loger le : #{Time.now}"
    @journal.the_model = 'setting'
    @journal.the_model_id = @setting.id
    @journal.user_id = current_user.id
    @journal.status = "Updated"
    @journal.save
    redirect_to settings_path, notice: "modification du parammêtre de calcul avec success."
  end

  private

  def set_setting
    @setting = Setting.find(params[:id])
  end

  def setting_params
    params.require(:setting).permit(:month_balance, :day_work_hour, :informing_before_duration, :number_items_of_page, :cancel_after_duration)
  end
end

