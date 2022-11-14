class ApplicationController < ActionController::Base
    before_action :authenticate_user!
    before_action :configure_permitted_parameters, if: :devise_controller?
    add_flash_types :success, :danger, :warning, :info

    private

    def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:sign_up, keys: [:matricule, :first_name, :last_name, :role_id, :personnal_email, :started_at, :phone_number,
            :job_title, :gender, :area_code, :family_status, :avatar, :line_manager_id, :fonctional_manager_id, :active, :home_adress, :manager_titles])
                                         
        devise_parameter_sanitizer.permit(:account_update, keys: [:role_id, :personnal_email, :area_code,:family_status, :avatar, :line_manager_id, :fonctional_manager_id, :active, :phone_number, :phone_number_fix, :home_adress, :manager_titles, :is_started_at_confirmed])
    end

    rescue_from CanCan::AccessDenied do |exception|
      redirect_to main_app.root_url, :alert => exception.message
    end

    def after_sign_in_path_for(resource)
        f_types_ids = FurloughType.where(is_payer: false).pluck(:id)
           
        furloughs = Furlough.where(user_id: resource.id, status: "Approuvé", furlough_type_id: f_types_ids)
        block = false
        furloughs.each do |f|
            f_type = FurloughType.find(f.furlough_type_id)
            if (Date.current.mjd - f.start.to_date.mjd) >= f_type.nbr_days_block
                block = true
            end
        end

        if block == true
            resource.is_active = false 
            resource.suspended!
            resource.save
        end 

        additional_hour_type_id = AdditionalHourType.find_by(code: "HSJFT").id
        hsjf = AdditionalHour.where(user_id: resource.id).where(status: 2).where(additional_hour_type_id: additional_hour_type_id)
        hsjf.each do |additional_hour_off|
            end_period = additional_hour_off.period.split(/ - */).last.to_date
            last_day_of_validity = end_period + 30.day
            if  Date.today >= last_day_of_validity
                additional_hour_off.expired!
                additional_hour_off.save

                bank = Bank.find_by(user_id: additional_hour_off.user_id)
                total_additional_hour = bank.balance_open_additional_hour_off_days - additional_hour_off.total_additional_hour_in_week
                bank.update(balance_open_additional_hour_off_days: total_additional_hour) 
            end
        end
   
        first_user = User.find(1)
        if resource.id != first_user.id && resource.is_started_at_confirmed == false
            if resource.sign_in_count < 10
                flash[:warning] = "Confirmer la date de votre integration sur la section compte de ton profil "
                edit_user_registration_path(current_user)
            else
                root_path
            end
        end
  
    end
end
