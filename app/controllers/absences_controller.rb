class AbsencesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_absence, only: %i[ show edit update destroy ]
  before_action :set_role, only: %i[ create update destroy export_absences ]

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
      Journal.create_journal(@role.title, current_user, "ajouté", "Absence", "une nouvelle entrée absence de", @absence.user.email, @absence.id, "Created")
      redirect_to absences_path, success: "L'absence a été créée avec succès." 
    else
      redirect_to absences_path, danger: "#{@absence.errors.full_messages}"
    end
  end

  # PATCH/PUT /absences/1
  def update
    if @absence.update(absence_params)
      Journal.create_journal(@role.title, current_user, "modifé", "Absence", "une entrée d'absence de", @absence.user.email, @absence.id, "Updated")
      redirect_to absences_path, success: "L'absence a été mis à jour avec succès." 
    else
      redirect_to absences_path, danger: "#{@absence.errors.full_messages}"
    end
  end

  # DELETE /absences/1
  def destroy
    @absence.destroy
    Journal.create_journal(@role.title, current_user, "supprimé", "Absence", "une entrée d'absence de", @absence.user.email, @absence.id, "Deleted")
    redirect_to absences_url, success: "L'absence a été supprimer avec succès." 
  end

  def pre_export_absences
  end

  def export_absences
    @absences = Absence.where(nil)
    @absences = Absence.exported_data_filtred(@absences, params)
    filename = "Rapport-absences-" + Date.today.to_s + ".xlsx" 
    Journal.create_journal(@role.title, current_user, "exporté", "Absence", "une list d'absences", nil, nil, "Exported")

    respond_to do |format|
      format.xlsx { headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" }
    end
  end

  private

    def set_absence
      @absence = Absence.find(params[:id])
    end

    def set_role
      @role = Role.find(current_user.role_id)
    end

    def absence_params
      params.require(:absence).permit(:start_time, :end_time, :user_id, :absence_type_id)
    end
end
