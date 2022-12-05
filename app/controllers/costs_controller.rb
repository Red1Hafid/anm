class CostsController < ApplicationController
  before_action :set_cost, only: [:show , :edit, :update, :destroy, :enable_cost, :disable_cost]

  def index
    @q = Cost.ransack(params[:q])
    @costs = Cost.all
    @setting = Setting.find(1)
    @costs = @q.result(distinct: true)
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
      flash[:notice] = "Cost was created successfully."
      redirect_to costs_path
    else
      render 'new'
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
         redirect_to costs_path
     end
  end

  def destroy
    if @cost.destroy
        redirect_to costs_path
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
    params.require(:cost).permit(:name, :percentage)
  end
end
