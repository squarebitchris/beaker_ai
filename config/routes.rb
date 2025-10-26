Rails.application.routes.draw do
  # Mount Sidekiq web UI (protected with admin authentication)
  require "sidekiq/web"
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end

  devise_for :users, controllers: {
    sessions: "devise/passwordless/sessions"
  }

  # Magic link authentication route
  devise_scope :user do
    get "/users/magic_link", to: "devise/passwordless/magic_links#show", as: :users_magic_link
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Custom health check with detailed status
  get "up" => "health#up", as: :health_check

  # Signup flow
  get "/signup", to: "signups#new", as: :new_signup
  post "/signup", to: "signups#create", as: :signups

  # Trial flow (authenticated)
  resources :trials, only: [ :new, :create, :show ] do
    member do
      post :call
    end
  end

  # Stripe checkout flow (Phase 3)
  resources :upgrades, only: [ :create ], param: :trial_id
  get "/upgrade/:trial_id", to: "upgrades#new", as: :new_upgrade

  # Onboarding flow (post-checkout provisioning)
  get "/onboarding", to: "onboarding#show", as: :onboarding
  get "/onboarding/status", to: "onboarding#status", as: :onboarding_status
  get "/success", to: "onboarding#success", as: :checkout_success
  get "/cancel", to: "onboarding#cancel", as: :checkout_cancel

  # Business dashboard (Phase 4)
  resources :businesses, only: [] do
    member do
      get :dashboard
    end
  end

  # Webhook endpoints
  post "/webhooks/stripe", to: "webhooks#create", defaults: { provider: "stripe" }
  post "/webhooks/twilio", to: "webhooks#create", defaults: { provider: "twilio" }
  post "/webhooks/vapi", to: "webhooks#create", defaults: { provider: "vapi" }

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Admin namespace
  namespace :admin do
    root to: "dashboard#index"

    resources :webhook_events, only: [ :index, :show ] do
      member do
        post :reprocess
      end
    end
    resources :businesses, only: [ :index, :show ]
    resources :users, only: [ :index, :show ]

    get "/search", to: "search#index", as: :search
  end

  # Authenticated users: redirect based on role
  authenticated :user do
    root to: redirect { |params, request|
      user = request.env["warden"].user
      business = user.businesses.first
      business ? dashboard_business_path(business) : new_trial_path
    }, as: :authenticated_root
  end

  root "signups#new"
end
