# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    respond_to :json

    private

    def respond_with(resource, _opts = {})
      if resource.persisted?
        render json: {
          message: 'Signed up successfully',
          user: UserSerializer.new(resource).serializable_hash[:data][:attributes]
        }, status: :created
      else
        render json: {
          error: 'User could not be created',
          message: resource.errors.full_messages
        }, status: :unprocessable_entity
      end
    end
  end
end
