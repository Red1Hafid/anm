class WelcomesController < ApplicationController
  before_action :authenticate_user!

  def index
    @search = AnalysisSearch.new(params[:search])
    @analysis = @search.get_analysis_between_two_date(current_user, @search.date_from, @search.date_to)
    if ['Super Admin', 'Rh'].include? current_user.role.title
      @number_furlough_soumis = Furlough.where(status: 'Soumis').count
      furloughs_type_ids = FurloughType.where(code: ['CEFMC', 'CEFME', 'CEFCE', 'CEFOC', 'CEFDA', 'CEFDF', 'CEFNE', 'CEFDC', 'CEFMA']).pluck(:id)
      array_furlough = []
      Furlough.where(furlough_type_id: furloughs_type_ids, status: ["Soumis", "Approuvé"]).each do |f| 
        if !f.documment.attached?
          array_furlough.push(f)
        end
      end 
      @number_refused_furlough = array_furlough.count
      @number_in_approuved_furlough = Furlough.where(status: 'Approuvé').count
      @number_in_canceled_furlough = Furlough.where(status: 'Annulé').count

      @number_authorization_soumis = Autorization.where(status: 3).count

      number_authorization_approuved = Autorization.where(status: 4)
      authorization_approuved = []
      number_authorization_approuved.each do |authorization|
        authorization__hour_duration = Autorization.get_hour_authorization_duration(authorization.date, authorization.start_hour, authorization.end_hour)
        if authorization__hour_duration >= 3 
          authorization_approuved.push(authorization)
        end
      end
      @number_authorization_approuved = authorization_approuved.count
    else
      @number_furlough_soumis = Furlough.where(status: 'Soumis', user_id: current_user.id).count
      @number_refused_furlough = Furlough.where(status: 'Refusé', user_id: current_user.id).count
      @number_in_approuved_furlough = Furlough.where(status: 'Approuvé', user_id: current_user.id).count
      @number_in_canceled_furlough = Furlough.where(status: 'Annulé', user_id: current_user.id).count

      @number_authorization_soumis = Autorization.where(status: 3, user_id: current_user.id).count

      number_authorization_approuved = Autorization.where(status: 4, user_id: current_user.id)
      authorization_approuved = []
      number_authorization_approuved.each do |authorization|
        authorization__hour_duration = Autorization.get_hour_authorization_duration(authorization.date, authorization.start_hour, authorization.end_hour)
        if authorization__hour_duration >= 3
          authorization_approuved.push(authorization)
        end
      end
      @number_authorization_approuved = authorization_approuved.count
    end
  end

  def en_cours_devlopement
  end

  def export()
    @search = AnalysisSearch.new(params[:search])
    @analysis = @search.get_analysis_between_two_date(current_user, params[:date_from].to_date, params[:date_to].to_date)
    filename = "KPI-" + "#{params[:date_from]}" + "_" + "#{params[:date_to]}" + ".xlsx" 

    respond_to do |format|
      format.xlsx { headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" }
    end
  end
end
