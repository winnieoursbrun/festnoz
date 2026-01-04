Rails.application.routes.draw do
  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check

  # Devise routes for authentication
  devise_for :users,
    path: 'api/auth',
    controllers: {
      sessions: 'users/sessions',
      registrations: 'users/registrations'
    },
    path_names: {
      sign_in: 'login',
      sign_out: 'logout',
      registration: 'signup'
    }

  # API routes
  namespace :api do
    namespace :v1 do
      # Current user endpoint
      get 'auth/me', to: 'auth#show'

      # Artists
      resources :artists, only: [:index, :show, :create, :update, :destroy] do
        member do
          get :concerts
          post :enrich
        end
      end

      # Concerts
      resources :concerts, only: [:index, :show, :create, :update, :destroy] do
        collection do
          get :nearby
          get :upcoming
        end
      end

      # User followed artists
      namespace :user do
        resources :followed_artists, only: [:index, :create] do
          collection do
            delete ':artist_id', action: :destroy, as: :destroy
          end
        end
      end
    end
  end

  # Root route - serves Vue app
  root 'home#index'

  # Catch-all route for Vue Router (must be last)
  # All non-API routes will be handled by the Vue app
  get '*path', to: 'home#index', constraints: ->(request) do
    !request.xhr? && request.format.html?
  end
end
