class FormationsController < ApplicationController
  before_action :set_formation, only: %i[ show edit update destroy ]

  # GET /formations or /formations.json
  def index
    @formations = Formation.all
    @setting = Setting.find(1)
  end

  # GET /formations/1 or /formations/1.json
  def show
  end

  # GET /formations/new
  def new
    @formation = Formation.new
  end

  # GET /formations/1/edit
  def edit
  end

  # POST /formations or /formations.json
  def create
    @formation = Formation.new(formation_params)

    respond_to do |format|
      if @formation.save
        format.html { redirect_to formations_path, notice: "Formation was successfully created." }
      else
        format.html { redirect_to formations_path, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /formations/1 or /formations/1.json
  def update
    respond_to do |format|
      if @formation.update(formation_params)
        format.html { redirect_to formations_path, notice: "Formation was successfully updated." }
      else
        format.html { redirect_to formations_path, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /formations/1 or /formations/1.json
  def destroy
    @formation.destroy

    respond_to do |format|
      format.html { redirect_to formations_url, notice: "Formation was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_formation
      @formation = Formation.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def formation_params
      params.require(:formation).permit(:total_hour, :start_date, :end_date, :description, :user_id, :formation_type_id, :is_done)
    end
end
