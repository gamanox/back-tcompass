Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    scope module: :v1 do
      resources :branches,only: [:show,:update] do
        member do
          post "groups",to: 'branches#assign_groups'
          post "toggle", to: "branches#toggle_is_active"
        end
      end
      resources :clients, only: [:index,:show,:create,:destroy] do
        collection do
          post 'branches',to: 'clients#create_branch'
          get 'branches', to: 'clients#index_branch'
        end
        member do
          post 'limits',to: 'admins#limit_assets'
        end
      end
      resources :comments, only: [] do
        collection do
          get "",to: 'messages#index'
        end
        member do
          get "", to: 'messages#show'
          post "", to: "messages#comment"
        end
      end
      resources :employees, only: [:index,:show,:destroy,:update] do
        collection do
          post "locations",  to: "users#employee_location"
          post 'shifts', to: 'employees#shifts'
          get  "locations", to: "users#locations"
          get "reports",to: 'employees#index_reports'
          get 'branches',to: 'employees#branches'
          get 'responses',to: 'employees#reports_done'
        end
        member do
          post "groups", to: "employees#assign_groups"
          post "toggle", to: "employees#change_status"
        end
      end
      resources :groups, only: [:index,:show] do
        collection do
          post "", to: "groups#create"
        end
        post "users", to: "groups#group_user"
      end
      get  "login",  to: "sessions#login"
      resources :messages,only: [:create] do
        member do
          post "",to: "messages#destroy"
          post 'read',to: 'messages#read'
        end
      end
      resources :reports,only: [:index,:create,:show] do
        collection do
          post "responses",to: 'reports#create_responses'
        end
        member do
          post "toggle",to: 'reports#toggle_is_active'
          post "groups",to: 'reports#assign_groups'
          get "export",to: 'reports#export'
          get "individual",to: 'reports#reporte_ind'
        end
      end
      post "signup", to: "sessions#signup"
      # Change this to something that makes sense
      get "users/employees", to: 'users#employees'
    end
  end





end
