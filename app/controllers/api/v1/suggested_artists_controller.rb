# frozen_string_literal: true

module Api
  module V1
    class SuggestedArtistsController < ApplicationController
      before_action :authenticate_user!

      # GET /api/v1/suggested_artists
      def index
        @suggested_artists = current_user.suggested_artists
                                         .includes(artist: [:user_artists, :concerts])
                                         .ordered
                                         .limit(50)

        render :index
      end

      # POST /api/v1/suggested_artists/sync
      def sync
        unless current_user.spotify_authenticated?
          return render json: { error: "Spotify authentication required" }, status: :unauthorized
        end

        spotify_service = SpotifyService.new(current_user)
        all_suggestions = spotify_service.sync_top_artists_to_suggestions(
          time_range: params[:time_range] || "medium_term",
          limit: params[:limit] || 20
        )

        @suggested_artists = current_user.suggested_artists
                                  .includes(artist: [:user_artists, :concerts])
                                  .ordered
                                  .limit(50)
        @message = "Successfully synced #{all_suggestions.count} suggested artists (#{@suggested_artists.count} new)"
        render :sync
      rescue StandardError => e
        Rails.logger.error("Failed to sync suggested artists: #{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))
        render json: { error: "Failed to sync suggested artists: #{e.message}" }, status: :unprocessable_entity
      end

      # DELETE /api/v1/suggested_artists/:id
      def destroy
        suggested_artist = current_user.suggested_artists.find(params[:id])
        suggested_artist.destroy

        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Suggested artist not found" }, status: :not_found
      end
    end
  end
end
