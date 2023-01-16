class NotesController < ApplicationController
  before_action :set_note, only: %i[show edit update destroy]

  def index
    @setting = Setting.find(1)
    @q = Note.ransack(params[:q])
    @costs = Cost.where(is_active: true).where(status: 'created')
    @users = User.all
    @notes =  @q.result(distinct: true)
  end

  def show
  end

  def new
    @note = Note.new

  end

  def create
    @note = Note.new(note_params)
    if ['Super Admin', 'Rh'].include? current_user.role.title
    else
      @note.user_id = current_user.id
    end
    @cost = Cost.find(@note.cost_id)
    if (Date.today.mjd - @note.facture_date.to_date.mjd) > 31
      redirect_to notes_path, warning: "Le retard est supérieur à un mois"
      else
    if @note.total > @cost.max_value
      redirect_to notes_path, warning: "Le cout du Note est plus grand que le max de frais"
    else
        if params[:documment].present?
          Note.update_note
        end
        if @note.save
          flash[:notice] = "La Note est créée avec succès."
          redirect_to notes_path, success: "La Note est créée avec succès"
        end
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
    params.require(:note).permit(:name, :facture_date, :total, :user_id, :cost_id, :documment)
  end
end
