class GroundsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_ground, only: [:show, :edit, :update, :destroy]
    load_and_authorize_resource
  
    def index
      if params[:search].present?
        @grounds = Ground.search(params)
      else
        @grounds = Ground.all
      end
      @setting = Setting.find(1)
    end
  
    def show
    end
  
    def new
      @ground = Ground.new
    end
  
    def edit
    end
  
    def create
      @ground = Ground.new(ground_params)
      @ground.save
      role = Role.find(current_user.role_id)
      @journal = Journal.new
      @journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à crée un nouveau motif - loger le : #{Time.now}"
      @journal.the_model = 'Motif'
      @journal.the_model_id = @ground.id
      @journal.user_id = current_user.id
      @journal.status = "Created"
      @journal.save
      redirect_to grounds_path
    end
  
    def update
      @ground.update(ground_params)
      role = Role.find(current_user.role_id)
      @journal = Journal.new
      @journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à modifié un motif - loger le : #{Time.now}"
      @journal.the_model = 'Motif'
      @journal.the_model_id = @ground.id
      @journal.user_id = current_user.id
      @journal.status = "Updated"
      @journal.save
      redirect_to grounds_path, notice: "Le motif a été bien modifé."
    end
  
    def destroy
      @ground.destroy
      role = Role.find(current_user.role_id)
      @journal = Journal.new
      @journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à supprimé un motif - loger le : #{Time.now}"
      @journal.the_model = 'Motif'
      @journal.the_model_id = @ground.id
      @journal.user_id = current_user.id
      @journal.status = "Deleted"
      @journal.save
      redirect_to grounds_path
    end

    def import
      Ground.import(params[:file])
      role = Role.find(current_user.role_id)
      @journal = Journal.new
      @journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à importé une list des motifs - loger le : #{Time.now}"
      @journal.the_model = 'Motif'
      @journal.user_id = current_user.id
      @journal.status = "Imported"
      @journal.save
      redirect_to grounds_path, notice: "la list des motifs a été bien importé."
    end
  
    private

    def set_ground
      @ground = Ground.find(params[:id])
    end

    def ground_params
      params.require(:ground).permit(:code, :description, :stop_action_id)
    end
end
  
