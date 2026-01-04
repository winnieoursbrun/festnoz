# frozen_string_literal: true

module Api
  module V1
    class ArtistsController < BaseController
      skip_before_action :authenticate_user!, only: [:index, :show, :concerts]
      before_action :require_admin, only: [:create, :update, :destroy, :enrich]
      before_action :set_artist, only: [:show, :update, :destroy, :concerts, :enrich]

      # GET /api/v1/artists
      def index
        @artists = Artist.all

        # Apply filters
        @artists = @artists.by_genre(params[:genre]) if params[:genre].present?
        @artists = @artists.search(params[:search]) if params[:search].present?

        # Order by name
        @artists = @artists.order(:name)

        render json: {
          artists: @artists.map { |artist| ArtistSerializer.new(artist).serializable_hash[:data][:attributes] }
        }, status: :ok
      end

      # GET /api/v1/artists/:id
      def show
        # Trigger lazy enrichment if not yet done
        schedule_lazy_enrichment if @artist.enrichment_pending?

        render json: {
          artist: ArtistSerializer.new(@artist).serializable_hash[:data][:attributes],
          is_following: current_user&.following?(@artist) || false,
          enrichment_status: @artist.audiodb_status
        }, status: :ok
      end

      # POST /api/v1/artists/:id/enrich
      def enrich
        if @artist.force_enrich!
          render json: {
            message: "Artist enriched successfully",
            artist: ArtistSerializer.new(@artist.reload).serializable_hash[:data][:attributes]
          }, status: :ok
        else
          render json: {
            message: "Artist not found in TheAudioDB",
            artist: ArtistSerializer.new(@artist).serializable_hash[:data][:attributes]
          }, status: :ok
        end
      end

      # GET /api/v1/artists/:id/concerts
      def concerts
        @concerts = @artist.upcoming_concerts

        render json: {
          concerts: @concerts.map { |concert| ConcertSerializer.new(concert).serializable_hash[:data][:attributes] }
        }, status: :ok
      end

      # POST /api/v1/artists
      def create
        @artist = Artist.new(artist_params)

        if @artist.save
          render json: {
            message: 'Artist created successfully',
            artist: ArtistSerializer.new(@artist).serializable_hash[:data][:attributes]
          }, status: :created
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
          render json: {
            message: 'Artist updated successfully',
            artist: ArtistSerializer.new(@artist).serializable_hash[:data][:attributes]
          }, status: :ok
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
