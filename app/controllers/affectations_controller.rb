class AffectationsController < ApplicationController
  before_action :set_affectation, only: %i[ show edit update destroy ]

  # GET /affectations or /affectations.json
  def index
    @setting = Setting.find(1)
    @affectations = Affectation.all
    @users = User.all
    @costs = Cost.where(is_active: true).where(status: 'created')
  end

  # GET /affectations/1 or /affectations/1.json
  def show
  end

  # GET /affectations/new
  def new
    @affectation = Affectation.new
  end

  # GET /affectations/1/edit
  def edit
  end

  # POST /affectations or /affectations.json
  def create
    @affectation = Affectation.new(affectation_params)

    respond_to do |format|
      if @affectation.save
        format.html { redirect_to affectation_url(@affectation), notice: "Affectation was successfully created." }
        format.json { render :show, status: :created, location: @affectation }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @affectation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /affectations/1 or /affectations/1.json
  def update
    respond_to do |format|
      if @affectation.update(affectation_params)
        format.html { redirect_to affectation_url(@affectation), notice: "Affectation was successfully updated." }
        format.json { render :show, status: :ok, location: @affectation }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @affectation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /affectations/1 or /affectations/1.json
  def destroy
    @affectation.destroy

    respond_to do |format|
      format.html { redirect_to affectations_url, notice: "Affectation was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_affectation
      @affectation = Affectation.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def affectation_params
      params.fetch(:affectation, {})
    end
end
