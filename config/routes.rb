Rails.application.routes.draw do
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

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "devise/sessions#new"
end
