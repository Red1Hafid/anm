class NotesController < ApplicationController
  before_action :set_note, only: %i[show edit update destroy]

  def index
    @setting = Setting.find(1)
    if ["Super Admin", "Rh"].include? current_user.role.title
      @q = Note.includes(:user, :cost).ransack(params[:q])
    else
      @user_projects = User.find_by(id: current_user.id).projects
      @q = Note.includes(:user, :cost).where(user_id: current_user).ransack(params[:q])
    end
    @costs = Cost.filter_by_active.filter_by_status(1)
    @users = User.where.not(role_id: 1)
    @projects = Project.filter_by_status(1)
    if params[:user_id]
      @projects = Project.where(user_id: params[:user_id])
    end
    @notes =  @q.result(distinct: true)
  end

  def mes_notes
    @user =  @user = User.find_by(id: current_user.id)
    @user_projects = @user.projects
    @notes = Note.mes_notes(current_user.id)
    @costs = Cost.filter_by_active.filter_by_status(1)
  end

  def project_users
    first_name = params[:name].split.first
    last_name = params[:name].split.last
    @user = User.find_by(first_name: first_name, last_name: last_name)
    result = {}
    result[:user_id] = @user.id
    @projects = @user.projects
    result[:projects] = @projects.pluck(:name)

    render :json => result
  end

  def show
  end

  def new
    @note = Note.new
  end

  def create
    @note = Note.new(note_params)
    if  @note.user_id.present? && @note.user_id != current_user.id
      is_administration = false
    else
      @note.user_id = current_user.id
      is_administration = true
    end
    @cost = Cost.find(@note.cost_id)
    message = ""
    if (Date.today.mjd - @note.facture_date.to_date.mjd) > 31
      message = "Le retard est supérieur à un mois"
    else
        if @note.total > @cost.max_value
          message = "Le cout du Note est plus grand que le max de frais"
        end
        if !Affectation.where(user_id: current_user.id)
          message = "Your not affected to any project"
        end
    end
    if @note.save
      if is_administration
        redirect_to mes_notes_path, success: "La Note est créée avec succès"
      else
        redirect_to notes_path, success: "La Note est créée avec succès"
      end
    else
      if is_administration
        redirect_to mes_notes_path, warning: message
      else
        redirect_to notes_path, warning: message
      end
    end
  end

  def edit
  end


  def update
     @note = Note.find(params[:id])
     if @note.update(note_params)
       if params[:documment].present?
         Note.update_note
       end
         puts("updated")
         redirect_to notes_path,  success: "La Note est édité avec succès"
     end
  end

  def destroy
    if @note.destroy
        redirect_to notes_path, success: "La Note est supprimé avec succès"
    end
  end



  private
    def set_note
      @note = Note.find(params[:id])
    end

  def note_params
    params.require(:note).permit(:name, :facture_date, :total, :user_id, :cost_id, :project_id, :documment)
  end
end
