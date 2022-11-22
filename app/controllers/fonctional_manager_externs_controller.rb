class FonctionalManagerExternsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_fonctional_manager_extern, only: [:show, :edit, :update, :destroy]
    load_and_authorize_resource
  
    def index
      @setting = Setting.find(1)
      @q = FonctionalManagerExtern.ransack(params[:q])
      @fonctional_manager_externs = @q.result(distinct: true)
    end
  
    def show
    end
  
    def new
      @fonctional_manager_extern = FonctionalManagerExtern.new
    end
  
    def edit
    end
  
    def create
      @fonctional_manager_extern = FonctionalManagerExtern.new(fonctional_manager_extern_params)
      @fonctional_manager_extern.save
      @fonctional_manager = FonctionalManager.create(matricule: @fonctional_manager_extern.id_external_manager, first_name: @fonctional_manager_extern.first_name, last_name: @fonctional_manager_extern.last_name)
      role = Role.find(current_user.role_id)
      @journal = Journal.new
      @journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à ajouter le gestionnaire externe (#{@fonctional_manager_extern.first_name} #{@fonctional_manager_extern.first_name}) - loger le : #{Time.now}"
      @journal.the_model = 'fonctionalManagerExtern'
      @journal.the_model_id = @fonctional_manager_extern.id
      @journal.user_id = current_user.id
      @journal.status = "Created"
      @journal.save
      redirect_to fonctional_manager_externs_path
    end
  
    def update
      @fonctional_manager = FonctionalManager.find_by(first_name: @fonctional_manager_extern.first_name, last_name: @fonctional_manager_extern.last_name)
      @fonctional_manager_extern.update(fonctional_manager_extern_params)
      @fonctional_manager.update(first_name: fonctional_manager_extern_params[:first_name], last_name: fonctional_manager_extern_params[:last_name])
      role = Role.find(current_user.role_id)
      @journal = Journal.new
      @journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à modifier le gestionnaire externe (#{@fonctional_manager_extern.first_name} #{@fonctional_manager_extern.first_name}) - loger le : #{Time.now}"
      @journal.the_model = 'fonctionalManagerExtern'
      @journal.the_model_id = @fonctional_manager_extern.id
      @journal.user_id = current_user.id
      @journal.status = "Created"
      @journal.save
      redirect_to fonctional_manager_externs_path
    end
  
    def destroy
      @fonctional_manager = FonctionalManager.find_by(first_name: @fonctional_manager_extern.first_name, last_name: @fonctional_manager_extern.last_name)
      @fonctional_manager_extern.destroy
      @fonctional_manager.destroy
      role = Role.find(current_user.role_id)
      @journal = Journal.new
      @journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à supprimer le gestionnaire externe (#{@fonctional_manager_extern.first_name} #{@fonctional_manager_extern.first_name}) - loger le : #{Time.now}"
      @journal.the_model = 'fonctionalManagerExtern'
      @journal.the_model_id = @fonctional_manager_extern.id
      @journal.user_id = current_user.id
      @journal.status = "Created"
      @journal.save
      redirect_to fonctional_manager_externs_path
    end

    def import
      FonctionalManagerExtern.import(params[:file])
      role = Role.find(current_user.role_id)
      @journal = Journal.new
      @journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à importer une liste des gestionnaires fonctionnel extern - loger le : #{Time.now}"
      @journal.the_model = 'fonctionalManagerExtern'
      @journal.user_id = current_user.id
      @journal.status = "Imported"
      @journal.save
      redirect_to fonctional_manager_externs_path, notice: "liste importé!."
    end
  
    private

    def set_fonctional_manager_extern
      @fonctional_manager_extern = FonctionalManagerExtern.find(params[:id])
    end

    def fonctional_manager_extern_params
      params.require(:fonctional_manager_extern).permit(:id_external_manager, :first_name, :last_name, :email, :job_title, :phone_number, :gender, :matricule)
    end
end
  

