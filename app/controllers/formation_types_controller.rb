class FormationTypesController < ApplicationController
  before_action :set_formation_type, only: %i[ show edit update destroy ]

  # GET /formation_types or /formation_types.json
  def index
    @formation_types = FormationType.all
    @setting = Setting.find(1)
  end

  # GET /formation_types/1 or /formation_types/1.json
  def show
  end

  # GET /formation_types/new
  def new
    @formation_type = FormationType.new
  end

  # GET /formation_types/1/edit
  def edit
  end

  # POST /formation_types or /formation_types.json
  def create
    @formation_type = FormationType.new(formation_type_params)

    respond_to do |format|
      if @formation_type.save
        format.html { redirect_to formation_types_path, notice: "Formation type was successfully created." }
      else
        format.html { redirect_to formation_types_path, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /formation_types/1 or /formation_types/1.json
  def update
    respond_to do |format|
      if @formation_type.update(formation_type_params)
        format.html { redirect_to formation_types_path, notice: "Formation type was successfully updated." }
      else
        format.html { redirect_to formation_types_path, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /formation_types/1 or /formation_types/1.json
  def destroy
    @formation_type.destroy

    respond_to do |format|
      format.html { redirect_to formation_types_path, notice: "Formation type was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_formation_type
      @formation_type = FormationType.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def formation_type_params
      params.require(:formation_type).permit(:description, :code)
    end
end
