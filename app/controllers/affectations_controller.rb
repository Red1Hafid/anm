class AffectationsController < ApplicationController
  before_action :set_affectation, only: %i[ show edit update destroy pre_disaffectation disaffectation]

  # GET /affectations or /affectations.json
  def index
    @setting = Setting.find(1)
    if params[:status].present?
      @q = Affectation.includes(:project, :user).ransack(params[:q])
      @affectations = @q.result(distinct: true).filter_by_status(2)
    else
      @q = Affectation.includes(:project, :user).ransack(params[:q])
      @affectations = @q.result(distinct: true).filter_by_status(1)
    end
    @users = User.all
    @projects = Project.where(is_active: true).where(status: 'created')
  end

  # GET /affectations/1 or /affectations/1.json
  def show
  end

  # GET /affectations/new
  def new
    @affectation = Affectation.new
    @projects = Project.where(is_active: true).where(status: 'created')
  end

  def pre_mes_affectations_new
  end

  # GET /affectations/1/edit
  def edit
  end

  # POST /affectations or /affectations.json
  def create
    @affectation = Affectation.new(affectation_params)
    if @affectation.user_id.present? && @affectation.user_id != current_user.id
      present = Affectation.custom_finder(@affectation.user_id, @affectation.project_id)
      is_administration = false
    else
      @affectation.user_id = current_user.id
      present = Affectation.custom_finder(current_user.id, @affectation.project_id)
      is_administration = true
    end
    if  present
      if is_administration
        redirect_to mes_affectations_path,  warning: "Affectation est déja crèes"
      else
        redirect_to affectations_path,  warning: "Affectation est déja crèes"
      end
    else
      if @affectation.save
        if is_administration
          redirect_to mes_affectations_path,  success: "Affectation est créé avec succès"
        else
          redirect_to affectations_path,  success: "Affectation est créé avec succès"
        end

      end
    end
  end

  def mes_affectations
    @projects = Project.where(is_active: true).where(status: 'created')
    @setting = Setting.find(1)
    if params[:status].present?
      @q = Affectation.ransack(params[:q])
      @affectations = Affectation.mes_affectation(current_user.id).filter_by_status(2)
    else
      @q = Affectation.ransack(params[:q])
      @affectations = Affectation.mes_affectation(current_user.id).filter_by_status(1)
    end
  end

  def pre_disaffectation
  end

  def collaborateurDesaffectation
  end

  # PATCH/PUT /affectations/1 or /affectations/1.json
  def update
    if @affectation.update(affectation_params)
      redirect_to affectations_url,  success: "Affectation Comments est édité avec succès"
    end
  end

  # DELETE /affectations/1 or /affectations/1.json
  def destroy
    if @affectation.destroy
      redirect_to affectations_url, success: "L'Affectation est supprimé avec succès"
    end
  end

  def disaffectation
    @affectation.update(disaffectation_params)
    @affectation.disaffected!
    @affectation.is_active = false
    if @affectation.save
      redirect_to affectations_path, success: "Le Collaborateur  est désaffecté avec succès."
    end
  end


  def disaffectation_through_project
    @affectation = Affectation.find_by(user_id: params[:user_id], project_id:  params[:project_id])
    @affectation.is_active = false
    @affectation.date_disacffectation = Date.today
    @affectation.disaffected!
    puts @affectation.status
    puts @affectation.is_active
    if @affectation.save
      redirect_to projects_path,  success: "Le Collaborateur  est désaffecté avec succès."
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_affectation
      @affectation = Affectation.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def affectation_params
      params.require(:affectation).permit(:user_id, :project_id, :date_affectation, :comments)
    end

  def disaffectation_params
    params.require(:affectation).permit(:date_disacffectation, :desaffectation_comments, :is_active)
  end

end