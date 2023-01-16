class UserConfsController < ApplicationController
  before_action :set_user_conf, only: %i[ show edit update destroy ]

  # GET /user_confs or /user_confs.json
  def index
    @user_confs = UserConf.all
  end

  # GET /user_confs/1 or /user_confs/1.json
  def show
  end

  # GET /user_confs/new
  def new
    @user_conf = UserConf.new
  end

  # GET /user_confs/1/edit
  def edit
  end

  # POST /user_confs or /user_confs.json
  def create
    @user_conf = UserConf.new(user_conf_params)

    respond_to do |format|
      if @user_conf.save
        format.html { redirect_to user_conf_url(@user_conf), notice: "User conf was successfully created." }
        format.json { render :show, status: :created, location: @user_conf }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user_conf.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_confs/1 or /user_confs/1.json
  def update
    respond_to do |format|
      if @user_conf.update(user_conf_params)
        format.html { redirect_to user_conf_url(@user_conf), notice: "User conf was successfully updated." }
        format.json { render :show, status: :ok, location: @user_conf }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user_conf.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_confs/1 or /user_confs/1.json
  def destroy
    @user_conf.destroy
    redirect_to user_confs_path 
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_conf
      @user_conf = UserConf.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_conf_params
      params.require(:user_conf).permit(:ref, :user_id, :cachet)
    end
end
