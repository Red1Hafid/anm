class CostsController < ApplicationController
  before_action :set_cost, only: [:show , :edit, :update, :destroy, :enable_cost, :disable_cost, :delete_cost]

  def index
    @setting = Setting.find(1)
    if params[:status].present?
      @q = Cost.ransack(params[:q])
      @costs = @q.result(distinct: true).where(status: 2)
    else
      @q = Cost.ransack(params[:q])
      @costs = @q.result(distinct: true).where(status: 1)
    end
  end


  def show
  end

  def new
    @cost = Cost.new
  end

  def create
    @cost = Cost.new(cost_params)
    @cost.is_active = true
    @cost.enabled_date = Date.today
    if @cost.save
      flash[:notice] = "Le coût est créé avec succès."
      redirect_to costs_path,  success: "Le coût est créé avec succès."
    else
      #render 'new'
    end
  end

  def find_cost_id
    name = params[:name].split.first
    puts name
    cost = Cost.find_by(name: name)
    render :json => cost.id
  end

  def edit
  end


  def update
     @cost = Cost.find(params[:id])
     if @cost.update(cost_params)
         puts("updated")
         redirect_to costs_path,  success: "Le Frais est édité avec succès"
     end
  end

  def delete_cost
    @cost.is_active = false
    @cost.disabled_date = Date.today
    @cost.deleted!
    if @cost.save
      redirect_to costs_path, notice: "Le Frais est supprimé avec succès."
    end
  end

  def destroy
    if @cost.destroy
        redirect_to costs_path, success: "Le Frais est supprimé avec succès"
    end
  end

  def disable_cost
    @cost.is_active = false
    @cost.disabled_date = Date.today
    if @cost.save
      redirect_to costs_path, success: "Le Frais est désactivé avec succès"
    end
  end

  def enable_cost
    @cost.is_active = true
    @cost.enabled_date = Date.today
    if @cost.save
      redirect_to costs_path, success: "Le Frais est activé avec succès"
    end
  end


  private
    def set_cost
      @cost = Cost.find(params[:id])
    end

  def cost_params
    params.require(:cost).permit(:name, :percentage, :max_value)
  end
end
