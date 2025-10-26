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

  # Upgrade intent (Phase 2 placeholder, Phase 3 Stripe checkout)
  get "/upgrade/:trial_id", to: "upgrades#new", as: :new_upgrade

  # Webhook endpoints
  post "/webhooks/stripe", to: "webhooks#create", defaults: { provider: "stripe" }
  post "/webhooks/twilio", to: "webhooks#create", defaults: { provider: "twilio" }
  post "/webhooks/vapi", to: "webhooks#create", defaults: { provider: "vapi" }

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Authenticated users go to trials, guests see signup
  authenticated :user do
    root to: "trials#new", as: :authenticated_root
  end

  root "signups#new"
end
