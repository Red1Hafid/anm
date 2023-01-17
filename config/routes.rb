require 'sidekiq/web'

Rails.application.routes.draw do
  resources :interns
  resources :formations
  resources :formation_types
  resources :user_confs
  resources :certificate_requests
  resources :template_attestations
  resources :absences
  resources :absence_types

  get 'settings/index'
  mount Sidekiq::Web => "/sidekiq", as: :sidekiq

  resources :users, only: [:create, :update] do
    collection { post :import }
  end
  devise_scope :user do
    devise_for :users, :controllers => {:registrations => "my_devise/registrations"}
    resources :users, except: [:create, :update]

    
    get "/users/sign_up",  :to => 'welcomes#index'
   
    authenticated :user do
      root 'welcomes#index', as: :authenticated_root
    end
  
    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_root
    end   
  end

  root 'welcomes#index'
  get '/export' => 'welcomes#export', as: 'export'
  get '/en-cours-developement' => 'welcomes#en_cours_devlopement', as: 'en_cours_devlopement'


  get '/congés', to: 'welcomes#furloughs_calendar', as: :conges
  get '/calendar', to: 'calendars#index', as: :calendar

  get 'enable/:id' => 'users#enable', as: 'enable'
  get 'disable/:id' => 'users#pre_disable', as: 'pre_disable'
  post 'disable/:id' => 'users#disable', as: 'disable'
  get '/users/role/:title', to: 'users#users_by_role', as: :users_by_role

  resources :furloughs
  get 'validate/:id' => 'furloughs#validate', as: 'validate'
  get 'approuve/:id' => 'furloughs#valide_fc', as: 'valide_fc'
  get 'in_progress/:id' => 'furloughs#in_progress', as: 'in_progress'
  get 'soumettre/:id' => 'furloughs#soumettre', as: 'soumettre'
  get 'mes-congés' => 'furloughs#furloughs_administration', as: 'furloughs_administration'
  get 'congé/:id' => 'furloughs#show_administration', as: 'show_administration'
  get 'refuse/:id' => 'furloughs#pre_refuse', as: 'pre_refuse'
  post 'refuse/:id' => 'furloughs#refuse', as: 'refuse'
  get 'cancel/:id' => 'furloughs#pre_cancel', as: 'pre_cancel'
  post 'cancel/:id' => 'furloughs#cancel', as: 'cancel'
  get 'print/:id' => 'furloughs#to_print', as: 'print'
  get 'findtypefurlough/:id' => 'furloughs#find_furlough_type', as: 'find_furlough_type'
  get 'getitemtohiligh/' => 'furloughs#get_item_to_hiligh', as: 'get_item_to_hiligh'
  get 'findfonctionalmanagerid/:name' => 'furloughs#find_fonctional_manager_id', as: 'find_fonctional_manager_id'
  get 'finduserid/:name' => 'furloughs#find_user_id', as: 'find_user_id'
  get 'findlinemanagerid/:name' => 'furloughs#find_line_manager_id', as: 'find_line_manager_id'
  get 'takeStartDate/:start_date/:type_furlough' => 'furloughs#take_start_date', as: 'take_start_date'
  get 'discontinuity/:id' => 'furloughs#pre_discontinuity', as: 'pre_discontinuity'
  post 'discontinuity/:id' => 'furloughs#discontinuity', as: 'discontinuity'
  get 'regularized/:id' => 'furloughs#pre_regularized', as: 'pre_regularized'
  post 'regularized/:id' => 'furloughs#regularized', as: 'regularized'
  get 'stop/:id' => 'furloughs#pre_stop', as: 'pre_stop'
  post 'stop/:id' => 'furloughs#stop', as: 'stop'
  get 'adjust/:id' => 'offs#pre_adjust', as: 'pre_adjust'
  post 'adjust/:id' => 'offs#adjust', as: 'adjust'

  get '/start_load' =>  'load_updated_files#start_load', as: 'start_load'



  

  #for js routes
  get 'duration_hour_taken/:user_id/:start/:hour_start/:end/:hour_end' => 'furloughs#duration_hour_taken', as: 'duration_hour_taken'
  get 'duration_taken/:start/:hour_start/:end/:hour_end' => 'furloughs#durations_taken', as: 'duration_taken'

  #settings
  resources :settings
  resources :stop_actions
  resources :grounds

  resources :costs
  get 'archivedcost' => 'costs#archived_cost', as: 'archived_cost'
  get 'disablecost/:id' => 'costs#disable_cost', as: 'disable_cost'
  get 'enablecost/:id' => 'costs#enable_cost', as: 'enable_cost'
  get 'findcostid/:name' => 'costs#find_cost_id', as: 'find_cost_id'
  get 'deletecost/:id' => 'costs#delete_cost', as: 'delete_cost'
  get 'unarchivecost/:id' => 'costs#unarchive_cost', as: 'unarchive_cost'


  resources :notes
  get 'mes-notes' => 'notes#mes_notes', as: 'mes_notes'

  resources :projects
  get 'deleteproject/:id' => 'projects#delete_project', as: 'delete_c'
  get 'disableproject/:id' => 'projects#disable_project', as: 'disable_project'
  get 'enableproject/:id' => 'projects#enable_project', as: 'enable_project'
  get 'findprojectid/:name' => 'projects#find_project_id', as: 'find_project_id'
  get 'deleteproject/:id' => 'costs#delete_project', as: 'delete_project'
  get 'unarchiveproject/:id' => 'projects#unarchive_project', as: 'unarchive_project'
  get 'disaffectation/:user_id/:project_id' => 'affectations#disaffectation_through_project', as: 'project_disaffectation'

  resources :affectations
  get 'disaffectation/:id' => 'affectations#pre_disaffectation', as: 'pre_disaffectation'
  post 'disaffectation/:id' => 'affectations#disaffectation', as: 'disaffectation'
  get 'mes-affectations' => 'affectations#mes_affectations', as: 'mes_affectations'

  resources :furlough_types do
    collection { post :import }
  end
  get 'enablefurloughtype/:id' => 'furlough_types#enable_furlough_type', as: 'enable_furlough_type'
  get 'disablefurloughtype/:id' => 'furlough_types#disable_furlough_type', as: 'disable_furlough_type'


  resources :offs do
    collection { post :import }
  end

  resources :fonctional_manager_externs do
    collection { post :import }
  end

  resources :stop_actions do
    collection { post :import }
  end

  resources :grounds do
    collection { post :import }
  end


  resources :journals
  resources :fonctional_manager_externs
  resources :additional_hours
  get 'soumettreHeuresSup/:id' => 'additional_hours#soumettre_additional_hour', as: 'soumettre_additional_hour'
  get 'mes-heures-sup' => 'additional_hours#additional_hours_administration', as: 'additional_hours_administration'

  get 'period/:additional_hour_date' => 'additional_hours#get_period', as: 'get_period'
  get 'days_of_input_form/:period' => 'additional_hours#get_days_of_input_form', as: 'get_days_of_input_form'
  get 'valid_hours/:start/:hour_start/:end/:hour_end' => 'additional_hours#get_valid_hours', as: 'get_valid_hours'

  resources :autorizations
  get 'soumettreAuthorization/:id' => 'autorizations#soumettre_autorization', as: 'soumettre_autorization'
  get 'validateAuthorization/:id' => 'autorizations#validate_autorization', as: 'validate_autorization'
  get 'refuseAuthorization/:id' => 'autorizations#refuse_autorization', as: 'refuse_autorization'
  get 'mes-authorisations' => 'autorizations#authorizations_administration', as: 'authorizations_administration'
  get 'authorization_hour_taken/:user_id/:date/:start_hour/:end_hour' => 'autorizations#duration_hour_taken_of_authorization', as: 'duration_hour_taken_of_authorization'
  get 'printauthorisation/:id' => 'autorizations#to_print_authorisation', as: 'to_print_authorisation'
  get 'recovered/:id' => 'autorizations#pre_recovered', as: 'pre_recovered'
  post 'recovered/:id' => 'autorizations#recovered', as: 'recovered'

  #Export rapport
  get 'export-authorizations' => 'autorizations#pre_export_authorizations', as: 'pre_export_authorizations'
  get 'export-authorizations-lolo' => 'autorizations#export_authorizations', as: 'export_authorizations'
  get 'export-absences' => 'absences#pre_export_absences', as: 'pre_export_absences'
  get 'export-absences-lolo' => 'absences#export_absences', as: 'export_absences'
  get 'export-heures-sup' => 'additional_hours#pre_export_additional_hours', as: 'pre_export_additional_hours'
  get 'export-heures-sup-lolo' => 'additional_hours#export_additional_hours', as: 'export_additional_hours'


  get 'printAttestation/:id' => 'certificate_requests#to_print', as: 'print_attestation'

  get 'mes-demandes-attestations' => 'certificate_requests#certificate_requests_administration', as: 'certificate_requests_administration'
  get 'validate-attestation/:id' => 'certificate_requests#validate_certificate', as: 'validate_certificate'
  get 'certificate/:id' => 'certificate_requests#pre_certificate', as: 'pre_certificate'
  post 'certificate/:id' => 'certificate_requests#certificate', as: 'certificate'
  get 'refus-certificate/:id' => 'certificate_requests#pre_refus_certificate', as: 'pre_refus_certificate'
  post 'refuscertificate/:id' => 'certificate_requests#refus_certificate', as: 'refus_certificate'

  
end
