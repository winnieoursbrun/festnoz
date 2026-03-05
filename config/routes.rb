Rails.application.routes.draw do
  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA manifest and service worker (Rails 8 native)
  get "/manifest.json", to: "rails/pwa#manifest", as: :pwa_manifest
  get "/service-worker.js", to: "rails/pwa#service_worker", as: :pwa_service_worker

  # Devise routes for authentication
  devise_for :users,
    path: "api/auth",
    controllers: {
      sessions: "users/sessions",
      registrations: "users/registrations",
      omniauth_callbacks: "api/auth/omniauth_callbacks"
    },
    path_names: {
      sign_in: "login",
      sign_out: "logout",
      registration: "signup",
      sign_up: ""  # Makes the signup URL cleaner: /api/auth/signup instead of /api/auth/signup/sign_up
    },
    skip: [ :registrations ]

  # Custom registration routes for cleaner URLs
  devise_scope :user do
    get "api/auth/signup", to: "users/registrations#new", as: :new_user_registration
    post "api/auth/signup", to: "users/registrations#create", as: :user_registration
    get "api/auth/signup/cancel", to: "users/registrations#cancel", as: :cancel_user_registration
    get "api/auth/signup/edit", to: "users/registrations#edit", as: :edit_user_registration
    patch "api/auth/signup", to: "users/registrations#update"
    put "api/auth/signup", to: "users/registrations#update"
    delete "api/auth/signup", to: "users/registrations#destroy"
  end

  # Redirect routes for cleaner OAuth URLs (without double /auth)
  get "api/auth/spotify", to: redirect("/api/auth/auth/spotify")
  get "api/auth/spotify/callback", to: redirect("/api/auth/auth/spotify/callback")

  # OmniAuth failure route
  get "/api/auth/failure", to: "api/auth/omniauth_callbacks#failure"

  # API routes
  namespace :api do
    namespace :v1 do
      # Current user endpoint
      get "auth/me", to: "auth#show"

      # Account settings (self-service)
      namespace :account do
        get "settings", to: "settings#show"
        patch "settings/profile", to: "settings#update_profile"
        patch "settings/password", to: "settings#update_password"
        delete "settings/music_accounts/:provider", to: "settings#disconnect_music_account"
        post "deletion/request", to: "settings#request_account_deletion"
        post "deletion/confirm", to: "deletion_confirmations#create"
        get "push_subscriptions/public_key", to: "push_subscriptions#public_key"
        resources :push_subscriptions, only: [ :index, :create, :destroy ] do
          collection do
            post :test
          end
        end
      end

      # Artists
      resources :artists, only: [ :index, :show, :create, :update, :destroy ] do
        collection do
          post :fetch_all_events
          get  :search_spotify
          post :import_from_spotify
        end
        member do
          get :concerts
          post :enrich
          post :fetch_events
        end
      end

      # Concerts
      resources :concerts, only: [ :index, :show, :create, :update, :destroy ] do
        collection do
          get :nearby
          get :upcoming
        end
      end

      # User followed artists
      namespace :user do
        resources :followed_artists, only: [ :index, :create ] do
          collection do
            delete ":artist_id", action: :destroy, as: :destroy
          end
        end
      end

      # Suggested artists
      resources :suggested_artists, only: [ :index, :destroy ] do
        collection do
          post :sync
        end
      end

      # Users (admin only)
      resources :users, only: [ :index, :show, :create, :update, :destroy ]
    end
  end

  # Root route - serves Vue app
  root "home#index"

  # Catch-all route for Vue Router (must be last)
  # All non-API routes will be handled by the Vue app
  get "*path", to: "home#index", constraints: ->(request) do
    !request.xhr? && request.format.html? && !request.path.start_with?("/api")
  end
end
