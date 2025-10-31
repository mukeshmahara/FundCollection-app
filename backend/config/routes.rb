Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  namespace :api do
    namespace :v1 do
      devise_for :users,
        path: "",
        path_names: {
          sign_in: "login",
          sign_out: "logout",
          registration: "signup"
        },
        controllers: {
          sessions: "api/v1/sessions",
          registrations: "api/v1/registrations"
        }

      devise_scope :user do
        post "login_with_phone", to: "sessions#login_with_phone"
        post "verify_otp", to: "sessions#verify_otp"
      end
      
      post "/refresh", to: "tokens#refresh"
      resources :campaigns do
        member do
          post :donate
          get :donations
        end
      end

      resources :donations, only: [ :index, :show, :create ]
      resources :users, only: [ :show, :update ]

      # Admin routes
      namespace :admin do
        resources :campaigns
        resources :donations, only: [ :index, :show ]
        resources :users, only: [ :index, :show ]
        get :dashboard, to: "dashboard#index"
      end

  # Payment routes
  post "/payments/create_payment_intent", to: "payments#create_payment_intent"
  post "/payments/confirm", to: "payments#confirm"
  post "/webhooks/stripe", to: "webhooks#stripe"
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
