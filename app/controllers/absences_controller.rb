class AbsencesController < ApplicationController
  before_action :set_absence, only: %i[ show edit update destroy ]

  # GET /absences
  def index
    @setting = Setting.find(1)
    if params[:code_absence_type].present? 
      @absences = AbsenceType.find_by(code: params[:code_absence_type]).absences
    else
      @absences = Absence.all
    end
  end

  # GET /absences/1
  def show
  end

  # GET /absences/new
  def new
    @absence = Absence.new
  end

  # GET /absences/1/edit
  def edit
  end

  # POST /absences
  def create
    @absence = Absence.new(absence_params)
    if @absence.save
      redirect_to absences_path, success: "Absence was successfully created." 
    else
      redirect_to absences_path, danger: "#{@absence.errors.full_messages}"
    end
  end

  # PATCH/PUT /absences/1
  def update
    if @absence.update(absence_params)
      redirect_to absences_path, success: "Absence was successfully updated." 
    else
      redirect_to absences_path, danger: "#{@absence.errors.full_messages}"
    end
  end

  # DELETE /absences/1
  def destroy
    @absence.destroy
    redirect_to absences_url, success: "Absence was successfully destroyed." 
  end

  def pre_export_absences
  end

  def export_absences
    @absences = Absence.where(nil)
    @absences = Absence.exported_data_filtred(@absences, params)
    filename = "Rapport-absences-" + Date.today.to_s + ".xlsx" 

    respond_to do |format|
      format.xlsx { headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" }
    end
  end

  private

    def set_absence
      @absence = Absence.find(params[:id])
    end

    def absence_params
      params.require(:absence).permit(:start_time, :end_time, :user_id, :absence_type_id)
    end
end
