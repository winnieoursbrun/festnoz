# frozen_string_literal: true

module Api
  module V1
    class AuthController < BaseController
      # GET /api/v1/auth/me
      def show
        render json: {
          user: UserSerializer.new(current_user).serializable_hash[:data][:attributes]
        }, status: :ok
      end
    end
  end
end
