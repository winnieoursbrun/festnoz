# frozen_string_literal: true

module Api
  module V1
    class UsersController < BaseController
      before_action :require_admin
      before_action :set_user, only: [ :show, :update, :destroy ]

      # GET /api/v1/users
      def index
        @users = ::User.includes(:followed_artists).order(created_at: :desc)
        render json: @users.map { |user| user_json(user) }
      end

      # GET /api/v1/users/:id
      def show
        render json: user_json(@user)
      end

      # POST /api/v1/users
      def create
        @user = ::User.new(user_create_params)

        if @user.save
          render json: user_json(@user), status: :created
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/users/:id
      def update
        update_params = user_update_params
        # Remove password if blank (don't update password if not provided)
        update_params.delete(:password) if update_params[:password].blank?

        if @user.update(update_params)
          render json: user_json(@user)
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/users/:id
      def destroy
        if @user == current_user
          render json: { error: "You cannot delete your own account" }, status: :forbidden
          return
        end

        @user.destroy
        head :no_content
      end

      private

      def set_user
        @user = ::User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "User not found" }, status: :not_found
      end

      def user_create_params
        # Extract params from either flat or nested structure
        extracted_params = params[:user].present? ? params[:user] : params
        extracted_params.permit(:email, :username, :admin, :password)
      end

      def user_update_params
        # Extract params from either flat or nested structure
        extracted_params = params[:user].present? ? params[:user] : params
        extracted_params.permit(:email, :username, :admin, :password)
      end

      def user_json(user)
        {
          id: user.id,
          email: user.email,
          username: user.username,
          admin: user.admin?,
          provider: user.provider,
          spotify_authenticated: user.spotify_authenticated?,
          followed_artists_count: user.followed_artists.size,
          created_at: user.created_at,
          updated_at: user.updated_at,
          last_sign_in_at: user.last_sign_in_at,
          sign_in_count: user.sign_in_count
        }
      end
    end
  end
end
