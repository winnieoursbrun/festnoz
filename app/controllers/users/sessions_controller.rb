# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    respond_to :json, :html

    # Allow accessing login page even if already authenticated
    # This is useful for JWT-based auth where users might want to get a new token
    skip_before_action :require_no_authentication, only: [ :new, :create ]

    # Override new to prevent respond_with being called on GET
    def new
      super
    end

    # Override create to handle POST login
    def create
      super
    end

    private

    def respond_with(resource, _opts = {})
      # Only process if resource is actually persisted (logged in)
      return super unless resource.persisted?

      if request.format.json?
        # API request - return JSON with token
        render json: {
          message: "Logged in successfully",
          user: UserSerializer.new(resource).serializable_hash[:data][:attributes]
        }, status: :ok
      else
        # HTML request from Devise views - redirect to frontend with token
        token = generate_jwt_token(resource)
        redirect_to frontend_auth_success_url(token), allow_other_host: true
      end
    end

    def generate_jwt_token(user)
      payload = {
        sub: user.id,
        scp: "user",
        aud: nil,
        iat: Time.now.to_i,
        exp: (Time.now + 1.week).to_i,
        jti: SecureRandom.uuid
      }
      secret_key = Rails.application.credentials.devise_jwt_secret_key || Rails.application.credentials.secret_key_base
      JWT.encode(payload, secret_key, "HS256")
    end

    def frontend_auth_success_url(token)
      base_url = ENV.fetch("URL", "http://127.0.0.1:3000")
      base_url = "http://#{base_url}" unless base_url.start_with?("http")
      "#{base_url}/auth/success?token=#{token}"
    end

    def respond_to_on_destroy
      if request.headers["Authorization"].present?
        secret_key = Rails.application.credentials.devise_jwt_secret_key || Rails.application.credentials.secret_key_base
        jwt_payload = JWT.decode(
          request.headers["Authorization"].split(" ").last,
          secret_key,
          true,
          { algorithm: "HS256" }
        ).first

        current_user = User.find(jwt_payload["sub"])
      end

      if current_user
        render json: {
          message: "Logged out successfully"
        }, status: :ok
      else
        render json: {
          error: "Could not logout",
          message: "User is not logged in"
        }, status: :unauthorized
      end
    rescue JWT::DecodeError => e
      render json: {
        error: "Invalid token",
        message: e.message
      }, status: :unauthorized
    end
  end
end
