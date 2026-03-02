# frozen_string_literal: true

module Api
  module V1
    module Account
      class DeletionConfirmationsController < ApplicationController
        respond_to :json

        # POST /api/v1/account/deletion/confirm
        def create
          token = params[:token].to_s
          user = ::User.find_by_valid_account_deletion_token(token)

          if user.nil?
            render json: { error: "Invalid or expired deletion token" }, status: :unprocessable_entity
            return
          end

          user.destroy!
          render json: { message: "Account deleted successfully" }, status: :ok
        end
      end
    end
  end
end
