class InternsController < ApplicationController
  before_action :set_intern, only: %i[ show edit update destroy ]

  # GET /interns or /interns.json
  def index
    @interns = Intern.all
    @setting = Setting.find(1)
  end

  # GET /interns/1 or /interns/1.json
  def show
  end

  # GET /interns/new
  def new
    @intern = Intern.new
  end

  # GET /interns/1/edit
  def edit
  end

  # POST /interns or /interns.json
  def create
    @intern = Intern.new(intern_params)
    @intern.technical_skills = params[:technical_skills].split(",")

    respond_to do |format|
      if @intern.save
        format.html { redirect_to interns_url, notice: "Intern was successfully created." }
      else
        format.html { redirect_to interns_url, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /interns/1 or /interns/1.json
  def update
    respond_to do |format|
      if @intern.update(intern_params)
        format.html { redirect_to interns_url, notice: "Intern was successfully updated." }
      else
        format.html { redirect_to interns_url, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /interns/1 or /interns/1.json
  def destroy
    @intern.destroy

    respond_to do |format|
      format.html { redirect_to interns_url, notice: "Intern was successfully destroyed." }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_intern
      @intern = Intern.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def intern_params
      params.require(:intern).permit(:matricule, :first_name, :last_name, :email, :gsm, :college_year, :past_interview, :opinion_interview, :is_passable, :desired_internship, :potential_internship, :opinion_internship, language_skills: [])
    end
   
end
