class StopActionsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_stop_action, only: [:show, :edit, :update, :destroy]
    load_and_authorize_resource
  
    def index
      if params[:search].present?
        @stop_actions = StopAction.search(params)
      else
        @stop_actions = StopAction.all
      end
      @setting = Setting.find(1)
    end
  
    def show
    end
  
    def new
      @stop_action = StopAction.new
    end
  
    def edit
    end
  
    def create
      @stop_action = StopAction.new(stop_action_params)
      @stop_action.save
      role = Role.find(current_user.role_id)
      @journal = Journal.new
      @journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à crée des actions d'arrêt - loger le : #{Time.now}"
      @journal.the_model = 'Action'
      @journal.the_model_id = @stop_action.id
      @journal.user_id = current_user.id
      @journal.status = "Created"
      @journal.save
      redirect_to stop_actions_path
    end
  
    def update
      @stop_action.update(stop_action_params)
      role = Role.find(current_user.role_id)
      @journal = Journal.new
      @journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à modifié une action - loger le : #{Time.now}"
      @journal.the_model = 'Action'
      @journal.the_model_id = @stop_action.id
      @journal.user_id = current_user.id
      @journal.status = "Updated"
      @journal.save
      redirect_to stop_actions_path, notice: "l'action a été bien modifé."
    end
  
    def destroy
      @stop_action.destroy
      role = Role.find(current_user.role_id)
      @journal = Journal.new
      @journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à supprimé une action - loger le : #{Time.now}"
      @journal.the_model = 'Action'
      @journal.the_model_id = @stop_action.id
      @journal.user_id = current_user.id
      @journal.status = "Deleted"
      @journal.save
      redirect_to stop_actions_path
    end

    def import
      StopAction.import(params[:file])
      role = Role.find(current_user.role_id)
      @journal = Journal.new
      @journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à importé des actions d'arrêt - loger le : #{Time.now}"
      @journal.the_model = 'Action'
      @journal.user_id = current_user.id
      @journal.status = "Imported"
      @journal.save
      redirect_to stop_actions_path, notice: "la list des actions a été bien importé."
    end
  
    private

    def set_stop_action
      @stop_action = StopAction.find(params[:id])
    end

    def stop_action_params
      params.require(:stop_action).permit(:code, :name)
    end
end
  
