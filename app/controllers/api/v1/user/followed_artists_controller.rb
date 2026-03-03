# frozen_string_literal: true

module Api
  module V1
    module User
      class FollowedArtistsController < BaseController
        # GET /api/v1/user/followed_artists
        def index
          @artists = current_user.followed_artists.includes(:user_artists, :concerts).order(:name)

          render :index, status: :ok
        end

        # POST /api/v1/user/followed_artists
        def create
          @artist = Artist.find(params[:artist_id])

          if current_user.following?(@artist)
            return render json: {
              error: 'Already following',
              message: 'You are already following this artist'
            }, status: :unprocessable_entity
          end

          current_user.follow(@artist)

          render :create, status: :created
        end

        # DELETE /api/v1/user/followed_artists/:artist_id
        def destroy
          @artist = Artist.find(params[:artist_id])

          unless current_user.following?(@artist)
            return render json: {
              error: 'Not following',
              message: 'You are not following this artist'
            }, status: :unprocessable_entity
          end

          current_user.unfollow(@artist)

          render json: {
            message: 'Artist unfollowed successfully'
          }, status: :ok
        end
      end
    end
  end
end
