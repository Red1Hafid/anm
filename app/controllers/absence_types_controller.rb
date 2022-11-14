class AbsenceTypesController < ApplicationController
  before_action :set_absence_type, only: %i[ show edit update destroy ]

  # GET /absence_types or /absence_types.json
  def index
    @absence_types = AbsenceType.all
    @setting = Setting.find(1)
  end

  # GET /absence_types/1 or /absence_types/1.json
  def show
  end

  # GET /absence_types/new
  def new
    @absence_type = AbsenceType.new
  end

  # GET /absence_types/1/edit
  def edit
  end

  # POST /absence_types or /absence_types.json
  def create
    @absence_type = AbsenceType.new(absence_type_params)

    
      if @absence_type.save
       redirect_to absence_types_path(@absence_type), notice: "Absence type was successfully created."
      end
    
  end

  # PATCH/PUT /absence_types/1 or /absence_types/1.json
  def update
    respond_to do |format|
      if @absence_type.update(absence_type_params)
        format.html { redirect_to absence_type_url(@absence_type), notice: "Absence type was successfully updated." }
        format.json { render :show, status: :ok, location: @absence_type }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @absence_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /absence_types/1 or /absence_types/1.json
  def destroy
    @absence_type.destroy

    respond_to do |format|
      format.html { redirect_to absence_types_url, notice: "Absence type was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_absence_type
      @absence_type = AbsenceType.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def absence_type_params
      params.require(:absence_type).permit(:code, :name)
    end
end
