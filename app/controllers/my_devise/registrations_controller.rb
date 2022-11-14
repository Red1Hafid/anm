class MyDevise::RegistrationsController < Devise::RegistrationsController
    protected 
    def after_update_path_for(resource)
      flash[:success] = "Vous avez bien modifié votre profil!"
      edit_user_registration_path(current_user)
    end
end