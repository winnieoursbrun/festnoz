# frozen_string_literal: true

module Api
  module V1
    module Account
      class SettingsController < BaseController
        # GET /api/v1/account/settings
        def show
          render json: { user: settings_user_json(current_user) }, status: :ok
        end

        # PATCH /api/v1/account/settings/profile
        def update_profile
          if current_user.update(profile_params)
            render json: {
              message: "Profile updated successfully",
              user: settings_user_json(current_user)
            }, status: :ok
          else
            render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
          end
        end

        # PATCH /api/v1/account/settings/password
        def update_password
          unless current_user.valid_password?(password_params[:current_password])
            render json: { errors: [ "Current password is incorrect" ] }, status: :unprocessable_entity
            return
          end

          if current_user.update(password: password_params[:password], password_confirmation: password_params[:password_confirmation])
            AccountMailer.password_changed(current_user).deliver_later
            render json: { message: "Password updated successfully" }, status: :ok
          else
            render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
          end
        end

        # DELETE /api/v1/account/settings/music_accounts/:provider
        def disconnect_music_account
          provider = params[:provider].to_s.downcase

          case provider
          when "spotify"
            current_user.update!(
              spotify_access_token: nil,
              spotify_refresh_token: nil,
              spotify_token_expires_at: nil
            )
            render json: {
              message: "Spotify account disconnected",
              user: settings_user_json(current_user)
            }, status: :ok
          else
            render json: { error: "Unsupported provider" }, status: :bad_request
          end
        end

        # POST /api/v1/account/deletion/request
        def request_account_deletion
          raw_token = current_user.generate_account_deletion_token!
          AccountMailer.account_deletion_confirmation(current_user, raw_token).deliver_later

          render json: {
            message: "We sent a confirmation link to your email. Click it to permanently delete your account."
          }, status: :ok
        end

        private

        def profile_params
          params.require(:user).permit(:username)
        end

        def password_params
          params.require(:user).permit(:current_password, :password, :password_confirmation)
        end

        def settings_user_json(user)
          {
            id: user.id,
            email: user.email,
            username: user.username,
            provider: user.provider,
            spotify_connected: user.spotify_authenticated?,
            music_accounts: {
              spotify: {
                connected: user.spotify_authenticated?
              }
            }
          }
        end
      end
    end
  end
end
