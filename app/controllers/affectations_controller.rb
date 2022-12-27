class AffectationsController < ApplicationController
  before_action :set_affectation, only: %i[ show edit update destroy pre_disaffectation disaffectation]

  # GET /affectations or /affectations.json
  def index
    @setting = Setting.find(1)
    @affectations = Affectation.all
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

  # GET /affectations/1/edit
  def edit
  end

  # POST /affectations or /affectations.json
  def create
    @affectation = Affectation.new(affectation_params)
    puts "----------------------------------------------------------------------------------------"
    puts "----------------------------------------------------------------------------------------"
    puts "----------------------------------------------------------------------------------------"
    puts "----------------------------------------------------------------------------------------"
    puts affectation_params
    if @affectation.save
      redirect_to affectations_path,  success: "Affectation est créé avec succès"
    end
  end

  def pre_disaffectation

  end

  def disaffectation
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_affectation
      @affectation = Affectation.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def affectation_params
      params.require(:affectation).permit(:user_id, :project_id, :date_affectation, :date_disacffectation, :comments)
    end
end
