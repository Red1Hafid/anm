class CalendarsController < ApplicationController
  before_action :authenticate_user!
  def index
    #if ["Super Admin", "Rh"].include? current_user.role.title 
      #@furloughs = Furlough.where(start: params[:start]..params[:end])
     # @furloughs_table = Furlough.all
   # else
     # @furloughs = Furlough.where(start: params[:start]..params[:end]).where(user_id: current_user)
      #@furloughs_table = Furlough.where(user_id: current_user)
   # end
  end
end
