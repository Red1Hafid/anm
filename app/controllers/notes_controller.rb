class NotesController < ApplicationController
  before_action :set_note, only: %i[show edit update destroy]

  def index
    @note = Note.all
  end

  def show
  end

  def new
    @note = Note.new
  end

  def create
    @note = Note.new(note_params)
    if @note.save
      redirect_to notes_path
    end
  end

  def edit
    #@cost = Cost.find(params[:id])
  end


  def update
     @cost = Cost.find(params[:id])
     if @cost.update(cost_params)
         puts("updated")
         redirect_to notes_path
     end
  end

  def destroy
    if @cost.destroy
        redirect_to notes_path
    end
  end


  private
    def set_note
      @cost = Note.find(params[:id])
    end

  def note_params
    params.require(:note).permit(:name)
  end
end
