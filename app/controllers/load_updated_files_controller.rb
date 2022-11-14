class LoadUpdatedFilesController < ApplicationController
    require 'sidekiq/api'
  
    before_action :back_home
  
    def index
    end
  
   
    def start_load
      p "======================"
      p "Import files"
      p "======================"
      attended_files = get_attended_files
      status_all_file = "Success"
      attended_files.each do |f|
        p "Started #{f} loading at #{Time.now.strftime("%I:%M:%S %z")}"
        @errors = UploadsManager.upload_file(f)
        if @errors.count > 0
          flash[:danger] = "L'import est s'arrété a cause des erreur dans le fichier #{f}"
          status_all_file = "Failed"
          break
        end
        p "Ended #{f} loading at #{Time.now.strftime("%I:%M:%S %z")}"
      end

      flash[:info] = "l'import est terminé" if status_all_file = "Success"
      redirect_to root_path
    end
  
    private
  
    # -- Utilities
  
    def back_home
      redirect_to :root unless current_user.role.title == 'Super Admin'
    end

    def get_attended_files
      attended_manual_files = [
         # 'd‚part-_action_.csv',
         # 'd‚part-motif.csv',
          '1.-types-de-congé.csv',
          '2.-jours-fériés.csv',
          '3.-gestionnaires-fonctionnels.csv',
          '4.-collaborateurs.csv',
          '5.-congés.csv',
          #'6.-heures-sup.csv',
          '7.-Autorisation.csv'    
      ]
  
      attended_manual_files
    end
  end
  