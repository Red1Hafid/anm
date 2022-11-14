class OffsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_off, only: [:pre_adjuste, :adjuste, :show, :edit, :update, :destroy]
    load_and_authorize_resource
  
    def index
      @setting = Setting.find(1)

      years = []
      Off.all.each { |o| years.push(o.start.year)}
      @all_years = years.uniq.sort.last(3)

      @results = {year: [], datas: []}

      @all_years.each do |year|
        values = Off.offs_by_year(year)
        @results[:year].push(year) 
        @results[:datas].push(values)
      end
    end
  
    def show
    end
  
    def new
      @off = Off.new
    end
  
    def edit
    end
  
    def create
      @off = Off.new(off_params)
      @off.color = "black"
      @off.save
      role = Role.find(current_user.role_id)
      @journal = Journal.new
      @journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à crée un jour férié à partir de #{@off.start} jusqu'a #{@off.end} - loger le : #{Time.now}"
      @journal.the_model = 'off'
      @journal.the_model_id = @off.id
      @journal.user_id = current_user.id
      @journal.status = "Created"
      @journal.save
      redirect_to offs_path
    end
  
    def update
      @off.update(edit_params)
      role = Role.find(current_user.role_id)
      @journal = Journal.new
      @journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à modifié un jour férié à partir de #{@off.start} jusqu'a #{@off.end} - loger le : #{Time.now}"
      @journal.the_model = 'off'
      @journal.the_model_id = @off.id
      @journal.user_id = current_user.id
      @journal.status = "Updated"
      @journal.save
      redirect_to offs_path, notice: "Day off imported."
    end
  
    def destroy
      @off.destroy
      role = Role.find(current_user.role_id)
      @journal = Journal.new
      @journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à supprimé un jour férié à partir de #{@off.start} jusqu'a #{@off.end} - loger le : #{Time.now}"
      @journal.the_model = 'off'
      @journal.the_model_id = @off.id
      @journal.user_id = current_user.id
      @journal.status = "Deleted"
      @journal.save
      redirect_to offs_path
    end

    def import
      Off.import(params[:file])
      role = Role.find(current_user.role_id)
      @journal = Journal.new
      @journal.content = "le #{role.title} (#{current_user.first_name} #{current_user.last_name}) à importé des jours férié - loger le : #{Time.now}"
      @journal.the_model = 'off'
      @journal.user_id = current_user.id
      @journal.status = "Imported"
      @journal.save
      redirect_to offs_path, notice: "Days off imported."
    end

    def pre_adjust
    end
  
    def adjust
      #AdjustsManager.adjust(@off, adjust_params)
      AdjustsWithCancelManager.adjust(@off, adjust_params)
      redirect_to offs_path, notice: "Le jour férié à bien été adjusté"
    end
  
    private

    def set_off
      @off = Off.find(params[:id])
    end

    def off_params
      params.require(:off).permit(:code, :title, :description, :start, :end)
    end

    def edit_params
      params.require(:off).permit(:title, :description)
    end

    def adjust_params
      params.require(:off).permit(:start, :end)
    end
end
  
