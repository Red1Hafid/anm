class ProjectsController < ApplicationController
  before_action :set_project, only: [ :show ,:edit , :update, :destroy , :delete_project, :enable_project, :disable_project, :unarchive_project ]

  # GET /projects or /projects.json
  def index
    @setting = Setting.find(1)
    if params[:status].present?
      @q = Project.ransack(params[:q])
      @projects = @q.result(distinct: true).where(status: 2)
    else
      @q = Project.ransack(params[:q])
      @projects = @q.result(distinct: true).where(status: 1)
    end
  end

  # GET /projects/1 or /projects/1.json
  def show
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects or /projects.json
  def create
    @project = Project.new(project_params)
    @project.is_active = true
    @project.enabled_date = Date.today
    @project.disabled_at = Date.today
    if @project.save
      flash[:notice] = "Le project est créé avec succès."
      redirect_to projects_path,  success: "Le project est créé avec succès."
    else
      redirect_to projects_path,  warning: "Une erreur sure la création du project."
    end
  end

  def find_project_id
    name = params[:name]
    project = Project.find_by(name: name)
    render :json => project.id
  end

  # PATCH/PUT /projects/1 or /projects/1.json
  def update
    if @project.update(project_params)
      redirect_to projects_path,  success: "Le Project est édité avec succès"
    end
  end

  def delete_project
    @project.is_active = false
    @project.disabled_at = Date.today
    @project.deleted!
    if @project.save
      redirect_to projects_path, notice: "Le project est supprimé avec succès."
    end
  end

  def unarchive_project
    @project.created!
    if @project.save
      redirect_to projects_path, notice: "Le project est désarchivé avec succès."
    end
  end

  # DELETE /projects/1 or /projects/1.json
  def destroy
    if @project.destroy
      redirect_to projects_path, notice: "Le project est suprimé avec succès."
    end
  end

  def disable_project
    @project.is_active = false
    if @project.save
      redirect_to projects_path, success: "Le project est désactivé avec succès"
    end
  end

  def enable_project
    @project.is_active = true
    @project.enabled_date = Date.today
    if @project.save
      redirect_to projects_path, success: "Le project est activé avec succès"
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def project_params
      params.require(:project).permit(:name, :description, :unit_affaire, :client)
    end
end
