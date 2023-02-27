class CertificateRequestsController < ApplicationController
  before_action :set_certificate_request, only: %i[ show edit update destroy validate_certificate pre_certificate certificate pre_refus_certificate refus_certificate to_print ]

  # GET /certificate_requests or /certificate_requests.json
  def index
    @setting = Setting.find(1)

    if ["Super Admin", "Rh"].include? current_user.role.title 
      @q = CertificateRequest.ransack(params[:q])
      @certificate_requests = @q.result(distinct: true)
    else
      @q = CertificateRequest.ransack(params[:q])
      @certificate_requests = @q.result(distinct: true).where(user_id: current_user.id)
    end
  end

  def certificate_requests_administration
    @setting = Setting.find(1)
    @certificate_requests_administration = CertificateRequest.where(user_id: current_user.id)
  end

  # GET /certificate_requests/1 or /certificate_requests/1.json
  def show
  end

  # GET /certificate_requests/new
  def new
    @certificate_request = CertificateRequest.new
  end

  # GET /certificate_requests/1/edit
  def edit
  end

  # POST /certificate_requests or /certificate_requests.json
  def create
    @certificate_request = CertificateRequest.new(certificate_request_params) 
    if ['Super Admin', 'Rh'].include? current_user.role.title
      if @certificate_request.user_id.present? && @certificate_request.user_id != current_user.id
        @certificate_request.save
        redirect_to certificate_requests_path, success: "Demande envoyé avec success"
      else
        @certificate_request = CertificateRequest.new(certificate_request_self_params)
        @certificate_request.user_id = current_user.id
        @certificate_request.save
        redirect_to certificate_requests_administration_path, success: "Demande envoyé avec success"
      end
    else 
      @certificate_request = CertificateRequest.new(certificate_request_self_params)
      @certificate_request.user_id = current_user.id
      @certificate_request.save
      redirect_to certificate_requests_path, success: "Demande envoyé avec success" 
    end
  end

  # PATCH/PUT /certificate_requests/1 or /certificate_requests/1.json
  def update
    respond_to do |format|
      if @certificate_request.update(certificate_request_params)
        format.html { redirect_to certificate_request_url(@certificate_request), notice: "Certificate request was successfully updated." }
        format.json { render :show, status: :ok, location: @certificate_request }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @certificate_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /certificate_requests/1 or /certificate_requests/1.json
  def destroy
    if ['Super Admin', 'Rh'].include? current_user.role.title
      if @certificate_request.user_id != current_user.id
        @certificate_request.destroy
        redirect_to certificate_requests_path
      else
        @certificate_request.destroy
        redirect_to certificate_requests_administration_path
      end
    else 
      @certificate_request.destroy
      redirect_to certificate_requests_path
    end
  end

  def validate_certificate 
    user_request = User.find(@certificate_request.user_id)
    @certificate_request.valide!
    @certificate_request.save
    #role = Role.find(current_user.role_id)
    #@journal = Journal.new
    #@journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à approuvé un congé á partir de #{@furlough.start} jusqu'a #{@furlough.end} - loger le : #{Time.now}"
    #@journal.the_model = 'furlough'
    #@journal.the_model_id = @furlough.id
    #@journal.user_id = current_user.id
    #@journal.status = "Approuvé"
    #@journal.save
    #FurloughMailer.with(furlough: @furlough).approuve_furlough_email.deliver_later
    redirect_to certificate_requests_path
  end

  def pre_certificate

  end

  def certificate
    if @certificate_request.update(certificate_params)
      redirect_to certificate_requests_path
    end
  end

  def pre_refus_certificate

  end

  def refus_certificate
    if @certificate_request.update(refus_certificate_params)
      @certificate_request.invalide!
      @certificate_request.save
      redirect_to certificate_requests_path
    end
  end

  def to_print
    @template_attestation = TemplateAttestation.find(@certificate_request.template_attestation_id)
    user = User.find(@certificate_request.user_id)

    rh = User.find(3)
    user_conf = UserConf.find_by(user_id: rh.id)
    respond_to do |format|
      paragraphe_1 = @template_attestation.paragraphe_1.gsub("%first_name%", user.first_name).gsub("%last_name%", user.last_name).gsub("%date_birth%", user.date_birth.to_s).gsub("%cin%", user.cin).gsub("%cnss%", user.cnss).gsub("%job_title%", user.job_title).gsub("%date_integration%", user.started_at.to_s).gsub("%gross_salary%", user.gross_salary.to_s)#.gsub("%date_end%", Date.today.to_s)
      doc = Loofah.fragment(paragraphe_1).scrub!(:strip)
      p1 = doc.text 

      paragraphe_2 = @template_attestation.paragraphe_2.gsub("%first_name%", user.first_name).gsub("%last_name%", user.last_name)
      doc = Loofah.fragment(paragraphe_2).scrub!(:strip)
      p2 = doc.text 

      paragraphe_3 = @template_attestation.paragraphe_3
      doc = Loofah.fragment(paragraphe_3).scrub!(:strip)
      p3 = doc.text 

      footer = @template_attestation.footer
      doc = Loofah.fragment(footer).scrub!(:strip)
      footer_pdf = doc.text 

      format.pdf do
        pdf = TemplateAttestationPdf.new(p1, p2, p3, footer_pdf, @template_attestation, rh, user_conf)
        send_data pdf.render, filename: 'Demande_attestation.pdf', type: 'application/pdf', disposition: "inline"
      end
    end
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_certificate_request
      @certificate_request = CertificateRequest.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def certificate_request_params
      params.require(:certificate_request).permit(:template_attestation_id, :user_id)
    end

    def certificate_request_self_params
      params.require(:certificate_request).permit(:template_attestation_id)
    end

    def certificate_params
      params.require(:certificate_request).permit(:certificate)
    end

    def refus_certificate_params
      params.require(:certificate_request).permit(:date_refus, :comment_refus)
    end
end
