# frozen_string_literal: true

module Api
  module V1
    class ArtistsController < BaseController
      skip_before_action :authenticate_user!, only: [:index, :show, :concerts]
      before_action :require_admin, only: [:create, :update, :destroy, :enrich, :fetch_events, :fetch_all_events, :search_spotify, :import_from_spotify]
      before_action :set_artist, only: [:show, :update, :destroy, :concerts, :enrich, :fetch_events]

      # GET /api/v1/artists
      def index
        @artists = Artist.all

        # Apply filters
        @artists = @artists.by_genre(params[:genre]) if params[:genre].present?
        @artists = @artists.search(params[:search]) if params[:search].present?

        # Eager load associations to avoid N+1 queries
        @artists = @artists.includes(:user_artists, :concerts).order(:name)

        render :index, status: :ok
      end

      # GET /api/v1/artists/:id
      def show
        # Trigger lazy enrichment if not yet done
        schedule_lazy_enrichment if @artist.enrichment_pending?

        @is_following = current_user&.following?(@artist) || false
        render :show, status: :ok
      end

      # POST /api/v1/artists/:id/enrich
      def enrich
        if @artist.force_enrich!
          @artist.reload
          @message = "Artist enriched successfully"
        else
          @message = "Artist not found in TheAudioDB"
        end
        render :enrich, status: :ok
      end

      # POST /api/v1/artists/fetch_all_events
      def fetch_all_events
        artist_ids = Artist.pluck(:id)
        artist_ids.each { |id| FetchArtistEventsJob.perform_later(id) }

        render json: {
          message: "Enqueued event fetching for #{artist_ids.size} artists",
          count: artist_ids.size
        }, status: :ok
      end

      # GET /api/v1/artists/search_spotify?q=query
      def search_spotify
        query = params[:q].to_s.strip
        return render json: { error: "Query is required" }, status: :bad_request if query.blank?

        results = SpotifyService.new.search_artists(query, limit: 10)
        spotify_ids = results.map { |r| r["id"] }.compact
        existing_ids = Artist.where(spotify_id: spotify_ids).pluck(:spotify_id).to_set

        artists = results.map do |r|
          {
            spotify_id: r["id"],
            name: r["name"],
            genre: r["genres"]&.first,
            genres: r["genres"],
            image_url: r["images"]&.first&.dig("url"),
            popularity: r["popularity"],
            spotify_url: r["external_urls"]&.dig("spotify"),
            followers: r.dig("followers", "total"),
            already_imported: existing_ids.include?(r["id"])
          }
        end

        render json: { artists: artists }, status: :ok
      rescue StandardError => e
        render json: { error: "Spotify search failed", message: e.message }, status: :service_unavailable
      end

      # POST /api/v1/artists/import_from_spotify
      def import_from_spotify
        spotify_id = params[:spotify_id].to_s.strip
        return render json: { error: "spotify_id is required" }, status: :bad_request if spotify_id.blank?

        existing = Artist.find_by(spotify_id: spotify_id)
        if existing
          return render json: {
            message: "Artist already imported",
            artist: { id: existing.id, name: existing.name, spotify_id: existing.spotify_id }
          }, status: :ok
        end

        artist = SpotifyService.new.import_artist(spotify_id)
        if artist&.persisted?
          render json: {
            message: "Artist imported successfully",
            artist: { id: artist.id, name: artist.name, spotify_id: artist.spotify_id }
          }, status: :created
        else
          render json: { error: "Failed to import artist" }, status: :unprocessable_entity
        end
      rescue StandardError => e
        render json: { error: "Spotify import failed", message: e.message }, status: :service_unavailable
      end

      # POST /api/v1/artists/:id/fetch_events
      def fetch_events
        result = @artist.fetch_events_now!

        render json: {
          message: "Successfully fetched events from Ticketmaster",
          created: result[:created],
          total: result[:total],
          errors: result[:errors]
        }, status: :ok
      rescue StandardError => e
        render json: {
          error: "Failed to fetch events",
          message: e.message
        }, status: :unprocessable_entity
      end

      # GET /api/v1/artists/:id/concerts
      def concerts
        @concerts = @artist.upcoming_concerts

        render :concerts, status: :ok
      end

      # POST /api/v1/artists
      def create
        @artist = Artist.new(artist_params)

        if @artist.save
          render :create, status: :created
        else
          render json: {
            error: 'Artist could not be created',
            message: @artist.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/artists/:id
      def update
        if @artist.update(artist_params)
          render :update, status: :ok
        else
          render json: {
            error: 'Artist could not be updated',
            message: @artist.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/artists/:id
      def destroy
        @artist.destroy
        render json: {
          message: 'Artist deleted successfully'
        }, status: :ok
      end

      private

      def set_artist
        @artist = Artist.find(params[:id])
      end

      def artist_params
        params.require(:artist).permit(
          :name,
          :description,
          :genre,
          :image_url,
          :country,
          :website
        )
      end

      def schedule_lazy_enrichment
        ArtistEnrichmentJob.perform_later(@artist.id)
      end
    end
  end
end
