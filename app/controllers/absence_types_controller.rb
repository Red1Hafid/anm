class AbsenceTypesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_absence_type, only: %i[ show edit update destroy ]
  before_action :set_role, only: %i[ create update destroy ]

  # GET /absence_types
  def index
    @setting = Setting.find(1)
    @absence_types = AbsenceType.all
  end

  # GET /absence_types/1
  def show
  end

  # GET /absence_types/new
  def new
    @absence_type = AbsenceType.new
  end

  # GET /absence_types/1/edit
  def edit
  end

  # POST /absence_types
  def create
    @absence_type = AbsenceType.new(absence_type_params)

    if @absence_type.save
      Journal.create_journal(@role.title, current_user, "ajouté", "AbsenceType", "un nouveau type d'absence", @absence_type.name, @absence_type.id, "Created")
      redirect_to absence_types_path(@absence_type), success: "Le type d'absence a été créé avec succès."
    else
      redirect_to absence_types_path(@absence_type), danger: "#{@absence_type.errors.full_messages}"
    end
  end

  # PATCH/PUT /absence_types/1
  def update
    if @absence_type.update(absence_type_params)
      Journal.create_journal(@role.title, current_user, "modifié", "AbsenceType", "le type d'absence", @absence_type.name, @absence_type.id, "Updated")
      redirect_to absence_type_url(@absence_type), success: "Le type d'absence a été mis à jour avec succès."  
    else
      redirect_to absence_type_url(@absence_type), danger: "#{@absence_type.errors.full_messages}"
    end
  end

  # DELETE /absence_types/1
  def destroy
    result = @absence_type.destroy_absence_type
    if result[:flash_type] == "success"
      Journal.create_journal(@role.title, current_user, "supprimé", "AbsenceType", "le type d'absence", @absence_type.name, @absence_type.id, "Deleted")
      redirect_to absence_types_url, success: "#{result[:message]}."
    else
      redirect_to absence_types_url, danger: "#{result[:message]}."
    end
  end

  private
  
    def set_absence_type
      @absence_type = AbsenceType.find(params[:id])
    end

    def set_role
      @role = Role.find(current_user.role_id)
    end

    def absence_type_params
      params.require(:absence_type).permit(:code, :name)
    end
end
