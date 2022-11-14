class AbsencesController < ApplicationController
  before_action :set_absence, only: %i[ show edit update destroy ]

  # GET /absences or /absences.json
  def index
    if params[:code_absence_type].present? 
      absence_type_id = AbsenceType.find_by(code: params[:code_absence_type]).id
      @absences = Absence.where(absence_type_id: absence_type_id)
    else
      @absences = Absence.all
    end
    @setting = Setting.find(1)
  end

  # GET /absences/1 or /absences/1.json
  def show
  end

  # GET /absences/new
  def new
    @absence = Absence.new
  end

  # GET /absences/1/edit
  def edit

  end

  # POST /absences or /absences.json
  def create
    @absence = Absence.new(absence_params)

    if @absence.save
      redirect_to absences_path, notice: "Absence was successfully created." 
    end
    
  end

  # PATCH/PUT /absences/1 or /absences/1.json
  def update
   
      if @absence.update(absence_params)
        redirect_to absences_path, notice: "Absence was successfully updated." 
      end
  
  end

  # DELETE /absences/1 or /absences/1.json
  def destroy
    @absence.destroy

    respond_to do |format|
      format.html { redirect_to absences_url, notice: "Absence was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def pre_export_absences
  
  end

  def export_absences
    @absences = Absence.where(nil)

    if params[:date_absence].present?
      if params[:oppeateur_date].present?
        case params[:oppeateur_date]
        when 'Supérieure que'
          @absences = @absences.filter_by_sup_date(params[:date_absence]) 
        when 'Inférieure que'
          @absences = @absences.filter_by_inf_date(params[:date_absence]) 
        when 'Égale'
          @absences = @absences.filter_by_egal_date(params[:date_absence]) 
        end
      end
    end

    if params[:type_absences].present?
      case params[:type_absences]
      when "Tous"
        code_absence_types = ['ABSJ','ABSI', 'ABST']
        ids_absence_type = AbsenceType.where(code: code_absence_types)
        @absences = @absences.filter_by_absence_type_ids(ids_absence_type) 
      when 'Absence Justifiée'
        code_absence_type = 'ABSJ'
        id_absence_type = AbsenceType.find_by(code: code_absence_type)
        @absences = @absences.filter_by_absence_type_id(id_absence_type) 
      when 'Absence Injustifiée'
        code_absence_type = 'ABSI'
        id_absence_type = AbsenceType.find_by(code: code_absence_type)
        @absences = @absences.filter_by_absence_type_id(id_absence_type) 
      when 'Accident de travail'
        code_absence_type = 'ABST'
        id_absence_type = AbsenceType.find_by(code: code_absence_type)
        @absences = @absences.filter_by_absence_type_id(id_absence_type) 
      end
    end

    puts "---------"
    puts @autorizations
    

    filename = "Rapport-absences-" + Date.today.to_s + ".xlsx" 
    respond_to do |format|
      format.xlsx { headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" }
    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_absence
      @absence = Absence.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def absence_params
      params.require(:absence).permit(:start_time, :end_time, :user_id, :absence_type_id)
    end
end
