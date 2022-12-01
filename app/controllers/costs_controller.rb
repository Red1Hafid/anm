class CostsController < ApplicationController
  before_action :set_cost, only: %i[show edit update destroy]

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
    @cost.user_id = current_user.id
    if @cost.save
      flash[:notice] = "Cost was created successfully."
      redirect_to costs_path
    else
      render 'new'
    end
  end

  def edit
  end


  def update
     @cost = Cost.find(params[:id])
     @cost.user_id = current_user.id
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


  private
    def set_cost
      @cost = Cost.find(params[:id])
    end

  def cost_params
    params.require(:cost).permit(:name, :percentage ,note_ids: [""])
  end
end
