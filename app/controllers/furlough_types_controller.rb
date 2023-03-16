class FurloughTypesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_furlough_type, only: [:show, :edit, :update, :destroy, :enable_furlough_type, :disable_furlough_type]
    before_action :set_role, only: %i[ create update destroy import enable_furlough_type disable_furlough_type]
    load_and_authorize_resource
  
    def index
      @setting = Setting.find(1)
      @furlough_types = FurloughType.all
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
      if @furlough_type.save
        Journal.create_journal(@role.title, current_user, "ajouté", "FurloughType", "un type de congé", @furlough_type.name, @furlough_type.id, "Created")
        redirect_to furlough_types_path, success: "Furlough type was successfully created." 
      else
        redirect_to furlough_types_path, danger: "#{@furlough_type.errors.full_messages}"
      end
    end
  
    def update
      if @furlough_type.update(furlough_type_params)
        Journal.create_journal(@role.title, current_user, "modifié", "FurloughType", "le type de congé", @furlough_type.name, @furlough_type.id, "Updated")
        redirect_to furlough_types_path, success: "Furlough type was successfully created." 
      else
        redirect_to furlough_types_path, danger: "#{@furlough_type.errors.full_messages}"
      end
    end
  
    def destroy
      result = @furlough_type.destroy_furlough_type
      if result[:flash_type] == "success"
        Journal.create_journal(@role.title, current_user, "supprimé", "FurloughType", "le type de congé", @furlough_type.name, @furlough_type.id, "Deleted")
        redirect_to furlough_types_path, success: "#{result[:message]}."
      else
        redirect_to furlough_types_path, danger: "#{result[:message]}."
      end
    end
  
    def import
      if FurloughType.import(params[:file])
        Journal.create_journal(@role.title, current_user, "importé", "FurloughType", "une list des type de congés", nil, nil, "Imported")
      end
      redirect_to furlough_types_path, notice: "types de congés importé."
    end

    def enable_furlough_type
      @furlough_type.is_actif = true
      @furlough_type.save
      Journal.create_journal(@role.title, current_user, "activé", "FurloughType", "le type de congé", @furlough_type.name, @furlough_type.id, "Enabled")
      redirect_to furlough_types_path, notice: "Le #{@furlough_type.name} a été activé avec succès."   
    end

    def disable_furlough_type
      @furlough_type.is_actif = false
      @furlough_type.save
      Journal.create_journal(@role.title, current_user, "désactivé", "FurloughType", "le type de congé", @furlough_type.name, @furlough_type.id, "Disabled")
      redirect_to furlough_types_path, notice: "Le #{@furlough_type.name} a été désactivé avec succès."   
    end

    private

    def set_furlough_type
      @furlough_type = FurloughType.find(params[:id])
    end

    def set_role
      @role = Role.find(current_user.role_id)
    end

    def furlough_type_params
      params.require(:furlough_type).permit(:name, :max_duration, :fixed_duration, :informing_before, :is_payer, :code, :nbr_days_block, :discontinuity_period, :discontinuity)
    end
end
  

