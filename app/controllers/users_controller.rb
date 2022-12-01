class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[ show edit update pre_disable disable destroy enable]

  def index 
    @q = User.ransack(params[:q])
    @setting = Setting.find(1)
    if params[:type].present? && ['Rh', 'Collaborateur'].include?(params[:type]) == true
      role_id = Role.find_by(title: params[:type]).id
      @users = User.where(role_id: role_id).order('created_at desc').page(params[:page]).per(10)
    else 
      role_id = Role.find_by(title: "Super Admin").id
      @users = @q.result(distinct: true).where.not(role_id: role_id).order('created_at desc').page(params[:page]).per(10)
    end

    @line_managers = User.where(manager_titles: ["Gestionnaire hiérarchique"]).or(User.where(manager_titles: ["Gestionnaire hiérarchique", "Gestionnaire fonctionnel"])).or(User.where(manager_titles: ["Gestionnaire fonctionnel", "Gestionnaire hiérarchique"]))
    @fonctional_managers = FonctionalManager.all 
    @stop_actions = StopAction.all.order(created_at: :asc)
    @grounds = Ground.all.order(created_at: :asc)
    

    respond_to do |format|
      format.xlsx
      format.html { render :index }
      format.csv
    end
  end

  def users_by_role
    role_id = Role.find_by(title: params[:title]).id
    @specific_users = User.users_by_role(role_id)
  end

  def functional_managers
    @setting = Setting.find(1)
    @managers = User.users_by_role(4).page(params[:page]).per(10)
  end

  def hierarchical_managers
    @setting = Setting.find(1)
    @managers = User.users_by_role(3).page(params[:page]).per(10)
  end

  def show
    @furloughs = Furlough.where(user_id: params[:id], status: "Approuvé").select {|num| num.start.year == DateTime.now.year || num.end.year == DateTime.now.year }
    @current_year_furloughs = @furloughs.group_by { |f| f.furlough_type.name }
    if !@user.line_manager_id.nil?
      @line_manager = User.find(@user.line_manager_id)
    end

    if !@user.fonctionnal_manager_id.nil?
      @fonctional_manager = FonctionalManager.find(@user.fonctionnal_manager_id)
    end
    
    @type_furlough = []
    @current_year_furloughs.each { |tp| @type_furlough << tp.first }

    @balance_furlough_day = Bank.find_by(user_id: params[:id]).balance_furlough
    @balance_furlough_day_réel = Furlough.get_balance_current_month(current_user.id)
    @balance_d = (@balance_furlough_day + @balance_furlough_day_réel).round(2)
  end

  def new
    @user = User.new
    @line_managers = User.where(manager_titles: ["Gestionnaire hiérarchique"]).or(User.where(manager_titles: ["Gestionnaire hiérarchique", "Gestionnaire fonctionnel"])).or(User.where(manager_titles: ["Gestionnaire fonctionnel", "Gestionnaire hiérarchique"]))
    @fonctional_managers = FonctionalManager.all 
  end

  def create
    @user = User.new(user_params)
    @user.status = :created
    @user.is_active = false
    @user.password = "Alithya"
    @user.password_confirmation = "Alithya"
    if @user.valid?
      @user.save
      if user_params[:manager_titles]
        if user_params[:manager_titles].include? "Gestionnaire fonctionnel"
          FonctionalManager.create(matricule: @user.matricule, first_name: @user.first_name, last_name: @user.last_name)
        end
      end

      Bank.create(user_id: @user.id, balance_furlough: 0.0, balance_open_additional_hour: 0, balance_open_additional_hour_off_days: 0)
      role = Role.find(@user.role_id)
      @journal = Journal.new
      @journal.content = "Nouveau #{role.title} (#{@user.first_name} #{@user.last_name}) à été crée de la part de #{current_user.first_name} #{current_user.last_name} - le : #{@user.created_at}"
      @journal.the_model = 'user'
      @journal.the_model_id = @user.id
      @journal.user_id = current_user.id
      @journal.status = "Nouveau"
      @journal.save
      redirect_to users_path, success: 'Le collaborateur a bien été crée'
    else
      flash.alert = "Le collaborateur n'a pas été crée"
      render :action => :new 
    end
  end

  def edit
    @line_managers = User.where(manager_titles: ["Gestionnaire hiérarchique"]).or(User.where(manager_titles: ["Gestionnaire hiérarchique", "Gestionnaire fonctionnel"])).or(User.where(manager_titles: ["Gestionnaire fonctionnel", "Gestionnaire hiérarchique"]))
    fonctional_manager_intern = User.where(manager_titles: ["Gestionnaire fonctionnel"])
    fonctional_manager_extern = FonctionalManagerExtern.all
    @fonctional_managers = FonctionalManager.all 
  end

  def destroy
    @user.destroy
    role = Role.find(@user.role_id)
    @journal = Journal.new
    @journal.content = "le #{role.title} (#{@user.first_name} #{@user.last_name}) à été supprimé de la part de #{current_user.first_name} #{current_user.last_name} - le : #{Time.now}"
    @journal.the_model = 'user'
    @journal.the_model_id = @user.id
    @journal.user_id = current_user.id
    @journal.status = "Deleted"
    @journal.save
    redirect_to users_url, notice: "Le Collaborateur a été supprimé avec succès."   
  end

  def pre_disable
    
  end

  def disable
    @user.update(user_disable_params)
    @user.desabled!
    @user.is_active = false
    @user.save
    role = Role.find(@user.role_id)
    @journal = Journal.new
    @journal.content = "le #{role.title} (#{@user.first_name} #{@user.last_name}) à été désactivé de la part de #{current_user.first_name} #{current_user.last_name} - le : #{Time.now}"
    @journal.the_model = 'user'
    @journal.the_model_id = @user.id
    @journal.user_id = current_user.id
    @journal.status = "Disable"
    @journal.save
    redirect_to users_path, notice: "Le Collaborateur a été désactivé avec succès."   
  end

  def enable
    @user.actif!
    @user.is_active = true
    @user.save
    role = Role.find(@user.role_id)
    @journal = Journal.new
    @journal.content = "le #{role.title} (#{@user.first_name} #{@user.last_name}) à été activé de la part de #{current_user.first_name} #{current_user.last_name} - le :  #{Time.now}"
    @journal.the_model = 'user'
    @journal.the_model_id = @user.id
    @journal.user_id = current_user.id
    @journal.status = "Enable"
    @journal.save
    redirect_to users_path, notice: "Le Collaborateur a été activé avec succès."   
  end

  def update
    @fonctional_manager = FonctionalManager.find_by(first_name: @user.first_name, last_name: @user.last_name)
    if @user.update(u_user_params)
      if u_user_params[:manager_titles]
        if u_user_params[:manager_titles].include? "Gestionnaire fonctionnel"
          if @fonctional_manager
            @fonctional_manager.update(first_name: u_user_params[:first_name], last_name: u_user_params[:last_name])
          else
            FonctionalManager.create(first_name: u_user_params[:first_name], last_name: u_user_params[:last_name])
          end  
        else u_user_params[:manager_titles] == ["Gestionnaire hiérarchique"]
          if @fonctional_manager
            @fonctional_manager.destroy
          end
        end
      else
        @user.update(manager_titles: u_user_params[:manager_titles])
        if @fonctional_manager
          @fonctional_manager.destroy
        end
      end
      role = Role.find(@user.role_id)
      @journal = Journal.new
      @journal.content = "le #{role.title} (#{@user.first_name} #{@user.last_name}) à été modifié de la part de #{current_user.first_name} #{current_user.last_name} - le :  #{@user.updated_at}"
      @journal.the_model = 'user'
      @journal.the_model_id = @user.id
      @journal.user_id = current_user.id
      @journal.status = "Updated"
      @journal.save
      redirect_to users_path 
    else 
      flash.alert = "Le collaborateur n'a pas été mis à jour."
      redirect_to users_path   
   end
  end

  def import
    User.import(params[:file])
    role = Role.find(current_user.role_id)
    @journal = Journal.new
    @journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à importé une list des utilisateurs - le : #{Time.now}"
    @journal.the_model = 'user'
    @journal.the_model_id = nil
    @journal.user_id = current_user.id
    @journal.status = "Imported"
    @journal.save
    redirect_to users_path, notice: "users imported."
  end


  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_disable_params
    params.require(:user).permit(:disabled_date, :stop_action_id, :ground_id, :disable_comment, :document)
  end

  def user_params
    params.require(:user).permit(:matricule, :first_name, :last_name, :email,
        :role_id, :started_at,:personnal_email, :job_title, :gender, :area_code,:family_status,:home_adress,
        :phone_number,:phone_number_fix, :avatar, :line_manager_id, :fonctionnal_manager_id, :active,:status, :sex, manager_titles: [])
  end

  def fonctional_extern_params
    params.require(:user).permit(:matricule, :first_name, :last_name, :email, :job_title, :gender, :area_code, :phone_number)
    end

  def u_user_params
    params.require(:user).permit(:first_name, :last_name, :email,
                                :role_id, :started_at,:personnal_email, :job_title, :gender, :area_code,:family_status,:home_adress,
                                :phone_number,:phone_number_fix, :avatar, :line_manager_id, :fonctionnal_manager_id, :active, :sex, manager_titles: [])
  end
        
end
