class NotesController < ApplicationController
  before_action :set_note, only: %i[show edit update destroy]

  def index
    @costs = Cost.where(is_active: true)
    @users = User.all
    @notes = Note.all
    @setting = Setting.find(1)
  end

  def show
  end

  def new
    @note = Note.new

  end

  def create
    puts "create"
    @note = Note.new(note_params)
    if ['Super Admin', 'Rh'].include? current_user.role.title
    else
      @note.user_id = current_user.id
    end
    if @note.save
      redirect_to notes_path
    end
  end

  def edit
    #@note = note.find(params[:id])
  end


  def update
     @note = Note.find(params[:id])
     if @note.update(note_params)
         puts("updated")
         redirect_to notes_path
     end
  end

  def destroy
    if @note.destroy
        redirect_to notes_path
    end
  end



  private
    def set_note
      @note = Note.find(params[:id])
    end

  def note_params
    params.require(:note).permit(:name, :total, :user_id, :cost_id, :document)
  end
end
