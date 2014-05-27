Arci::Application.routes.draw do
  get "books/codes"
  get "books/generate_code"
	#root :to => "users#dashboard"
  root :to => redirect("/users/sign_in")
  #devise_scope :user do
		#root to: "devise/sessions#new"
	#end
  
  resources :statuses
  
  get "qualifications/get_qualifications" => "qualifications#get_qualifications"
  
  devise_for :users, :controllers => {:registrations => "devise/registrations", :sessions => "devise/sessions", :passwords => "devise/passwords"}
  
  devise_scope :user do
  	get 'administrator' => 'devise/registrations#new', :as => :administrator_dashboard
  	get 'users' => 'devise/registrations#new'
  	get "user/edit_profile/:id" => "devise/registrations#edit", :as => :edit_user_profile
  	patch 'user/update_profile' => 'devise/registrations#update_profile', :as => :update_user_profile
  end
  #get 'user/edit_profile/:id' => 'users#edit_profile', :as => :edit_user_profile
  #get "user/edit_profile/:id" => "devise/registrations#edit", :as => :edit_user_profile
  #put 'user/update_profile' => 'users#update_profile', :as => :update_user_profile
  get 'user/search' => 'users#search', :as => :search_user
  get 'user/enable_profile/:id' => 'users#enable_profile', :as => :enable_user_profile
  get 'user/disable_profile/:id' => 'users#disable_profile', :as => :disable_user_profile
  get 'user/update_profile' => 'devise/registrations#new'
  
  get "departments" => "departments#index"
  post "department/create" => "departments#create"
  get "editer-un-departement/:department_id" => "departments#edit"
  get "désactiver-un-departement/:department_id" => "departments#disable", :as => :disable_department
  get "activer-un-departement/:department_id" => "departments#enable", :as => :enable_department
  post "department/update" => "departments#update"
  get "department/update" => "departments#index"  
  
  post "qualification/create" => "qualifications#create"
  get "editer-une-qualification/:qualification_id" => "qualifications#edit"
  get "désactiver-une-qualification/:qualification_id" => "qualifications#disable", :as => :disable_qualification
  get "activer-une-qualification/:qualification_id" => "qualifications#enable", :as => :enable_qualification
  post "qualification/update" => "qualifications#update"
  get "qualification/update" => "departments#index"  
  
  get "categories" => "categories#index"
  post "category/create" => "categories#create"
  get "editer-un-type-de-document/:category_id" => "categories#edit"
  get "désactiver-un-type-de-document/:category_id" => "categories#disable", :as => :disable_category
  get "activer-un-type-de-document/:category_id" => "categories#enable", :as => :enable_category
  post "category/update" => "categories#update"
  get "category/update" => "categories#index" 
  
  get "shafts" => "shafts#index"
  post "shaft/create" => "shafts#create"
  get "editer-un-puits/:shaft_id" => "shafts#edit"
  get "désactiver-un-puits/:shaft_id" => "shafts#disable", :as => :disable_shaft
  get "activer-un-puits/:shaft_id" => "shafts#enable", :as => :enable_shaft
  post "shaft/update" => "shafts#update"
  get "shaft/update" => "shafts#index"

  get "blocks/get_blocks" => "blocks#get_blocks"  
  post "block/create" => "blocks#create"
  get "editer-un-bloc/:block_id" => "blocks#edit"
  get "désactiver-un-bloc/:block_id" => "blocks#disable", :as => :disable_block
  get "activer-un-bloc/:block_id" => "blocks#enable", :as => :enable_block
  post "block/update" => "blocks#update"
  get "block/update" => "blocks#index"
  
  get "consultants" => "consultants#index"
  post "consultant/create" => "consultants#create"
  get "editer-un-organe-detude/:consultant_id" => "consultants#edit"
  get "désactiver-un-organe-detude/:consultant_id" => "consultants#disable", :as => :disable_consultant
  get "activer-un-organe-detude/:consultant_id" => "consultants#enable", :as => :enable_consultant
  post "consultant/update" => "consultants#update"
  get "consultant/update" => "consultants#index"  
  
  get "boites-darchives" => "archive_boxes#index"
  post "archive_box/create" => "archive_boxes#create"
  get "editer-une-boite-darchive/:archive_box_id" => "archive_boxes#edit"
  get "désactiver-une-boite-darchive/:archive_box_id" => "archive_boxes#disable", :as => :disable_archive_box
  get "activer-une-boite-darchive/:archive_box_id" => "archive_boxes#enable", :as => :enable_archive_box
  post "archive-box/update" => "archive_boxes#update"
  get "archive-box/update" => "archive_boxes#index"  
  
  get "creer-un-document-et-generer-son-code" => "books#codes", as: :generate_code
  post "books/search-available-books" => "books#search"
  post "recherche-parmis-tous-les-documents" => "books#search_all_books"
  post "books/search-unavailable-books" => "reservations#search_unavailable"
  post "book/create" => "books#create"
  get "book/create" => "books#codes"
  get "books/process_request" => "books#process_request", as: :process_request
  get "book/view-only" => "books#view_only", as: :only_view_book
  get "liste-des-documents-par-categorie" => "books#list", as: :list_books
  get "liste-des-documents-par-categorie/:category_id" => "books#list_books_per_category", as: :list_books_in_category
 
  get "nouvelle-demande-de-documents" => "books#send_request", as: :lv_dashboard  
  get "nouvelle-demande-de-documents" => "books#send_request", as: :cd_dashboard  
  get "nouvelle-demande-de-documents" => "books#send_request", as: :cd_bd_dashboard
  get "nouvelle-demande-de-documents" => "books#send_request", as: :csadp_bd_dashboard 
  get "documents-en-attente-de-retrait" => "demands#agc_validated", as: :agc_dashboard
  get "pe/liste-des-documents-par-categorie" => "books#list", as: :pe_dashboard
  get "book/new_request" => "books#send_request", as: :new_book_request
  get "editer-les-informations-du-document/:book_id" => "books#edit", as: :edit_book
  post "book/update" => "books#update"
  get "book/update" => "books#codes"
  get "activer-un-document/:book_id" => "books#enable_book", as: :enable_book
  get "desactiver-un-document/:book_id" => "books#disable_book", as: :disable_book
  
  get "demands/history" => "demands#history", as: :demands_history
  get "csadp/demandes-en-attente-de-validation" => "demands#csadp_bd_on_hold", as: :csadp_bd_demands_on_hold
  get "demandes-en-attente-de-validation" => "demands#lv_on_hold", as: :lv_demands_on_hold
  get "demandes-validees" => "demands#lv_validated", as: :lv_demands_validated
  get "demands/statistics" => "demands#statistics", as: :demands_statistics
  get "documents-a-retirer" => "demands#to_get_back", as: :lv_demands_to_get_back  
  get "csadp/demands/to_get_back" => "demands#csadp_bd_to_get_back", as: :csadp_bd_demands_to_get_back
  get "documents-en-attente-de-retrait" => "demands#agc_validated", as: :agc_validated_demands
  get "agc/documents-a-rendre" => "demands#agc_to_return", as: :agc_demands_to_return
  get "agc/brought_back" => "demands#agc_brought_back"
  get "agc/damaged" => "demands#agc_damaged"
  get "agc/partial_return" => "demands#agc_partial_return"
  get "agc/partial_damage" => "demands#agc_partial_damage"
  get "demands/global_validation" => "demands#global_validation"
  get "demands/global_rejection" => "demands#global_rejection"
  get "demands/lv_global_validation" => "demands#lv_global_validation"
  get "demands/lv_global_rejection" => "demands#lv_global_rejection"
  get "demands/agc_global_validation" => "demands#agc_global_validation"
  get "demands/agc_global_rejection" => "demands#agc_global_rejection"
  get "demands/agc_partial_validation" => "demands#agc_partial_validation"
  get "demands/agc_partial_rejection" => "demands#agc_partial_rejection"
  get "demands/global_demand_status" => "demands#global_demand_status"
  get "demands/partial_validation" => "demands#partial_validation"
  get "demands/partial_rejection" => "demands#partial_rejection"
  get "demands/lv_partial_validation" => "demands#lv_partial_validation"
  get "demands/lv_partial_rejection" => "demands#lv_partial_rejection"
  get "documents-a-rendre" => "demands#lv_to_bring_back", as: :lv_demands_to_bring_back
  get "lv/demands/lv_bring_back" => "demands#lv_bring_back"
  get "lv/demands/lv_damaged" => "demands#lv_damaged"
  get "lv/demands/partial_return" => "demands#lv_partial_return"
  get "lv/demands/partial_damage" => "demands#lv_partial_damage"
  get "demands/partial_demand_status" => "demands#partial_demand_status"
  
  get "agc_demands/history" => "demands#agc_history", as: :agc_demands_history
  
  get "liste-des-agents-du-centre" => "cdbd#list_library_agents", as: :list_library_agents
  get "donner-le-droit-de-validation/:id" => "cdbd#give_validation_right", as: :give_validation_right
  get "retirer-le-droit-de-validation/:id" => "cdbd#remove_validation_right", as: :remove_validation_right
  
  get "nouvelle-reservation-de-documents" => "reservations#index", as: :reservations
  get "reservation/create" => "reservations#create"
  get "liste-des-reservations-de-documents" => "reservations#list", as: :list_reservations
  
  get "rapports-generaux-de-demandes-de-documents" => "reports#global_reports", as: :global_reports
  get "rapports-personnels-de-demandes-de-documents" => "reports#personnal_reports", as: :personnal_reports
  get "historique-personnel-des-demandes-de-documents" => "reports#personnal_reports_history", as: :personnal_reports_history
  get "historique-personnel-de-la-liste-des-demandes-de-documents" => "reports#personnal_demands", as: :personnal_demands_list
  get "historique-des-demandes-de-documents-rejetees" => "reports#personnal_rejected_demands", as: :personnal_rejected_demands
  get "liste-des-documents-constituant-la-demande/:id" => "reports#list_documents_in_demand", as: :personnal_demand_documents_list  
  
  get "historique/demandes-en-attente/liste-par-qualification" => "reports#departments_on_hold", as: :demands_on_hold_per_qualification
  get "historique/demandes-en-attente/liste-des-utilisateurs/:qualification_id" => "reports#list_users_on_hold", as: :users_on_hold_demands_per_qualification
  get "historique/demandes-en-attente/liste-des-demandes/:user_id" => "reports#demands_on_hold", as: :demands_on_hold_report
  
  get "historique/demandes-rejetees/liste-par-qualification" => "reports#departments_rejected", as: :demands_rejected_per_qualification
  get "historique/demandes-rejetees/liste-des-utilisateurs/:qualification_id" => "reports#list_users_rejected", as: :users_rejected_demands_per_qualification
  get "historique/demandes-rejetees/liste-des-demandes/:user_id" => "reports#demands_rejected", as: :demands_rejected_report
  
  get "historique/demandes-validees/liste-par-qualification" => "reports#departments_validated", as: :demands_validated_per_qualification
  get "historique/demandes-validees/liste-des-utilisateurs/:qualification_id" => "reports#list_users_validated", as: :users_validated_demands_per_qualification
  get "historique/demandes-validees/liste-des-demandes/:user_id" => "reports#demands_validated", as: :demands_validated_report
  
  get "historique/demandes-a-retirer/liste-par-qualification" => "reports#departments_to_get_back", as: :demands_to_get_back_per_qualification
  get "historique/demandes-a-retirer/liste-des-utilisateurs/:qualification_id" => "reports#list_users_to_get_back", as: :users_to_get_back_demands_per_qualification
  get "historique/demandes-a-retirer/liste-des-demandes/:user_id" => "reports#demands_to_get_back", as: :demands_to_get_back_report
  
  get "historique/demandes-a-rendre/liste-par-qualification" => "reports#departments_to_bring_back", as: :demands_to_bring_back_per_qualification
  get "historique/demandes-a-rendre/liste-des-utilisateurs/:qualification_id" => "reports#list_users_to_bring_back", as: :users_to_bring_back_demands_per_qualification
  get "historique/demandes-a-rendre/liste-des-demandes/:user_id" => "reports#demands_to_bring_back", as: :demands_to_bring_back_report
  
  get "historique/demandes-rendues/liste-par-qualification" => "reports#departments_returned", as: :demands_returned_per_qualification
  get "historique/demandes-rendues/liste-des-utilisateurs/:qualification_id" => "reports#list_users_returned", as: :users_returned_demands_per_qualification
  get "historique/demandes-rendues/liste-des-demandes/:user_id" => "reports#demands_returned", as: :demands_returned_report
  #devise_scope :user do
  	#match '/users/sign_out' => 'devise/sessions#destroy'
  	#match 'create_user' => 'devise/registrations#new', :as => :dashboard_administrator
  	#match "users/search_ajax" => "devise/users#search_ajax"
  	#match "users/get_directions" => "devise/users#get_directions"
  	#match "users/get_workshops" => "devise/users#get_workshops"
  	#match "user/edit" => "devise/registrations#edit", :as => :edit_user
  	#match "users/enable" => "devise/users#enable", :as => :enable_user
  	#match "users/disable" => "devise/users#disable", :as => :disable_user
  	#match "users/delete" => "devise/users#delete", :as => :delete_user
  	#match 'user/update' => 'devise/users#update', :as => :update_user
  #end
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
