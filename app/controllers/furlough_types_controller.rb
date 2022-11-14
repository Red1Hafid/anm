class FurloughTypesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_furlough_type, only: [:show, :edit, :update, :destroy, :enable_furlough_type, :disable_furlough_type]
    load_and_authorize_resource
  
    def index
        @furlough_types = FurloughType.all
        @setting = Setting.find(1)
    end
  
    def show
    end
  
    def new
      @furlough_type = FurloughType.new
      @setting = Setting.find(1)
    end
  
    def edit
    end
  
    def create
      @furlough_type = FurloughType.new(furlough_type_params)
      @furlough_type.save
      role = Role.find(current_user.role_id)
      @journal = Journal.new
      @journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à crée un #{@furlough_type.name} - loger le : #{Time.now}"
      @journal.the_model = 'type_furlough'
      @journal.the_model_id = @furlough_type.id
      @journal.user_id = current_user.id
      @journal.status = "Created"
      @journal.save
      redirect_to furlough_types_path
    end
  
    def update
      @furlough_type.update(furlough_type_params)
      role = Role.find(current_user.role_id)
      @journal = Journal.new
      @journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à modifer le type de #{@furlough_type.name} - loger le : #{Time.now}"
      @journal.the_model = 'type_furlough'
      @journal.the_model_id = @furlough_type.id
      @journal.user_id = current_user.id
      @journal.status = "Updated"
      @journal.save
      redirect_to furlough_types_path
    end
  
    def destroy
      @furlough_type.destroy
      role = Role.find(current_user.role_id)
      @journal = Journal.new
      @journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à supprimé un #{@furlough_type.name} - loger le : #{Time.now}"
      @journal.the_model = 'type_furlough'
      @journal.the_model_id = @furlough_type.id
      @journal.user_id = current_user.id
      @journal.status = "Deleted"
      @journal.save
      redirect_to furlough_types_path
    end
  
    def import
      FurloughType.import(params[:file])
      role = Role.find(current_user.role_id)
      @journal = Journal.new
      @journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à impoté des type de congés - loger le : #{Time.now}"
      @journal.the_model = 'type_furlough'
      @journal.user_id = current_user.id
      @journal.status = "Imported"
      @journal.save
      redirect_to furlough_types_path, notice: "types de congés importé."
    end

    def enable_furlough_type
      @furlough_type.is_actif = true

      puts @furlough_type.is_actif
      @furlough_type.save
      role = Role.find(current_user.role_id)
      @journal = Journal.new
      @journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à activé le #{@furlough_type.name} - le :  #{Time.now}"
      @journal.the_model = 'type_furlough'
      @journal.the_model_id = @furlough_type.id
      @journal.user_id = current_user.id
      @journal.status = "Enable"
      @journal.save
      redirect_to furlough_types_path, notice: "Le #{@furlough_type.name} a été activé avec succès."   
    end

    def disable_furlough_type
      @furlough_type.is_actif = false
      @furlough_type.save
      role = Role.find(current_user.role_id)
      @journal = Journal.new
      @journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à désactivé le #{@furlough_type.name} - le :  #{Time.now}"
      @journal.the_model = 'type_furlough'
      @journal.the_model_id = @furlough_type.id
      @journal.user_id = current_user.id
      @journal.status = "Disable"
      @journal.save
      redirect_to furlough_types_path, notice: "Le #{@furlough_type.name} a été désactivé avec succès."   
    end

    private

    def set_furlough_type
      @furlough_type = FurloughType.find(params[:id])
    end

    def furlough_type_params
      params.require(:furlough_type).permit(:name, :max_duration, :fixed_duration, :informing_before, :is_payer, :code, :nbr_days_block, :discontinuity_period, :discontinuity)
    end
end
  

