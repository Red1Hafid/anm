class AbsenceTypesController < ApplicationController
  before_action :set_absence_type, only: %i[ show edit update destroy ]

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
      redirect_to absence_types_path(@absence_type), success: "Absence type was successfully created."
    else
      redirect_to absence_types_path(@absence_type), danger: "#{@absence_type.errors.full_messages}"
    end
  end

  # PATCH/PUT /absence_types/1
  def update
    if @absence_type.update(absence_type_params)
      redirect_to absence_type_url(@absence_type), success: "Absence type was successfully updated."  
    else
      redirect_to absence_type_url(@absence_type), danger: "#{@absence_type.errors.full_messages}"
    end
  end

  # DELETE /absence_types/1
  def destroy
    result = @absence_type.destroy_absence_type
    if result[:flash_type] == "success"
      redirect_to absence_types_url, success: "#{result[:message]}."
    else
      redirect_to absence_types_url, danger: "#{result[:message]}."
    end
  end

  private
  
    def set_absence_type
      @absence_type = AbsenceType.find(params[:id])
    end

    def absence_type_params
      params.require(:absence_type).permit(:code, :name)
    end
end
