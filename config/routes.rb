Rails.application.routes.draw do
  resource :user, only: [ :edit, :update ]
  resource :registration, only: [ :new, :create ]
  resource :session, except: [ :show ]
  resources :passwords, param: :token

  # Hydra OAuth2 Login and Consent endpoints
  get "/oauth/login", to: "oauth_login#show"
  post "/oauth/login", to: "oauth_login#create"
  get "/oauth/consent", to: "oauth_consent#show"
  post "/oauth/consent", to: "oauth_consent#create"

  # API endpoints
  namespace :api do
    namespace :v1 do
      get "/user/profile", to: "user#profile"
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "sessions#new"
end
