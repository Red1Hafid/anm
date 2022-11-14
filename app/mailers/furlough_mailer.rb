class FurloughMailer < ApplicationMailer
    def new_furlough_email
        @furlough = params[:furlough]
    
        mail(to: "redouaaneHafid@gmail.com", subject: "Vous avez reçu une nouvelle demande de congé pour validation!")
    end

    def approuve_furlough_email
        @furlough = params[:furlough]
        user = User.find(@furlough.user_id)
        line_manager = User.find(user.line_manager_id)
    
        mail(to: user.email, cc: line_manager.email, subject: "Congé validé")
    end

    def stop_furlough_email
        @furlough = params[:furlough]
        user = User.find(@furlough.user_id)
        line_manager = User.find(user.line_manager_id)
    
        mail(to: user.email, cc: line_manager.email, subject: "Congé arrêté")
    end

    def refuse_furlough_email
        @furlough = params[:furlough]
        user = User.find(@furlough.user_id)
        mail(to: user.email, subject: "Congé refusé")
    end

    def cancel_furlough_email
        @furlough = params[:furlough]
        user = User.find(@furlough.user_id)
        mail(to: user.email, subject: "Congé annulé")
    end

    def get_user_email
        email = User.find(@furlough.user_id).email
    end
end
