class FraisCategoryController < ApplicationController
  before_action :set_frais_category, only: %i[ show]

  def index
    @fraisCategory = FraiCategory.all
  end

  def show
  end

  def new
    @fraisCategory = FraiCategory.new
  end

  def set_frais_category
   @fraisCategory = FraiCategory.find(params[:id])
  end

  def fraisCategory_params
    params.require(:fraisCategory).permit(:name)
  end
end
