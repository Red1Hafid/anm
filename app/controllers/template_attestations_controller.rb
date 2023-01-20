class TemplateAttestationsController < ApplicationController
  before_action :set_template_attestation, only: %i[ show edit update destroy to_print ]

  # GET /template_attestations or /template_attestations.json
  def index
    @template_attestations = TemplateAttestation.all
    @setting = Setting.find(1)
  end

  # GET /template_attestations/1 or /template_attestations/1.json
  def show
   
  end

  # GET /template_attestations/new
  def new
    @template_attestation = TemplateAttestation.new
  end

  # GET /template_attestations/1/edit
  def edit
  end

  # POST /template_attestations or /template_attestations.json
  def create
    @template_attestation = TemplateAttestation.new(template_attestation_params)

    respond_to do |format|
      if @template_attestation.save
        format.html { redirect_to template_attestations_path, notice: "Template attestation was successfully created." }
        format.json { render :show, status: :created, location: @template_attestation }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @template_attestation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /template_attestations/1 or /template_attestations/1.json
  def update
    respond_to do |format|
      if @template_attestation.update(template_attestation_params)
        format.html { redirect_to template_attestations_path, notice: "Template attestation was successfully updated." }
        format.json { render :show, status: :ok, location: @template_attestation }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @template_attestation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /template_attestations/1 or /template_attestations/1.json
  def destroy
    @template_attestation.destroy

    respond_to do |format|
      format.html { redirect_to template_attestations_url, notice: "Template attestation was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_template_attestation
      @template_attestation = TemplateAttestation.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def template_attestation_params
      params.require(:template_attestation).permit(:name, :code, :paragraphe_1, :paragraphe_2, :paragraphe_3, :footer)
    end
end
