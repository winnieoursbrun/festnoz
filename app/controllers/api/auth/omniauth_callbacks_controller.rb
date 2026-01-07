# frozen_string_literal: true

module Api
  module Auth
    class OmniauthCallbacksController < Devise::OmniauthCallbacksController
      skip_before_action :verify_authenticity_token, only: [ :spotify, :failure, :passthru ]

      def spotify
        auth = request.env["omniauth.auth"]

        # Find or create user from OAuth data
        @user = User.from_omniauth(auth)

        if @user.persisted?
          # Generate JWT token for the user
          token = generate_jwt_token(@user)

          # Redirect to frontend with token
          redirect_to frontend_callback_url(token: token, provider: "spotify"), allow_other_host: true
        else
          # Redirect to frontend with error
          redirect_to frontend_callback_url(error: "authentication_failed"), allow_other_host: true
        end
      end

      def failure
        # Redirect to frontend with error
        error_message = params[:message] || "authentication_failed"
        redirect_to frontend_callback_url(error: error_message), allow_other_host: true
      end

      private

      def generate_jwt_token(user)
        # Use the same JWT generation logic as Devise JWT with all required claims
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

      def frontend_base_url
        # Use ENV variable or default to frontend dev server
        # In production, frontend and backend share the same URL
        url = ENV.fetch("URL", "http://127.0.0.1:3000")
        # Ensure URL has protocol
        url.start_with?("http") ? url : "http://#{url}"
      end

      def frontend_callback_url(query_params = {})
        # Build frontend auth success URL with query parameters
        # Use /auth/success to match sessions/registrations controllers
        uri = URI.parse(frontend_base_url)
        uri.path = "/auth/success"
        uri.query = query_params.to_query if query_params.any?
        uri.to_s
      end
    end
  end
end
