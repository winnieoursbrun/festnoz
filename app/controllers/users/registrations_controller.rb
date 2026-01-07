# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    respond_to :json, :html

    # Allow accessing signup page even if already authenticated
    # This is useful for JWT-based auth where users might want to create another account
    skip_before_action :require_no_authentication, only: [ :new, :create ]

    private

    def respond_with(resource, _opts = {})
      if request.format.json?
        # API request - return JSON
        if resource.persisted?
          render json: {
            message: "Signed up successfully",
            user: UserSerializer.new(resource).serializable_hash[:data][:attributes]
          }, status: :created
        else
          render json: {
            error: "User could not be created",
            message: resource.errors.full_messages
          }, status: :unprocessable_entity
        end
      else
        # HTML request from Devise views
        if resource.persisted?
          # Sign up successful - redirect to frontend with token
          token = generate_jwt_token(resource)
          redirect_to frontend_auth_success_url(token), allow_other_host: true
        else
          # Sign up failed - render form with errors (default Devise behavior)
          super
        end
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
  end
end
