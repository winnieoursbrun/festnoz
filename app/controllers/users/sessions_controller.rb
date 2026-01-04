# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    respond_to :json

    private

    def respond_with(resource, _opts = {})
      render json: {
        message: 'Logged in successfully',
        user: UserSerializer.new(resource).serializable_hash[:data][:attributes]
      }, status: :ok
    end

    def respond_to_on_destroy
      if request.headers['Authorization'].present?
        jwt_payload = JWT.decode(
          request.headers['Authorization'].split(' ').last,
          Rails.application.credentials.devise_jwt_secret_key || Rails.application.credentials.secret_key_base
        ).first

        current_user = User.find(jwt_payload['sub'])
      end

      if current_user
        render json: {
          message: 'Logged out successfully'
        }, status: :ok
      else
        render json: {
          error: 'Could not logout',
          message: 'User is not logged in'
        }, status: :unauthorized
      end
    rescue JWT::DecodeError
      render json: {
        error: 'Invalid token'
      }, status: :unauthorized
    end
  end
end
