Rails.application.routes.draw do
  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check

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

      # Artists
      resources :artists, only: [ :index, :show, :create, :update, :destroy ] do
        member do
          get :concerts
          post :enrich
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
