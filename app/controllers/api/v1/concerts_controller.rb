# frozen_string_literal: true

module Api
  module V1
    class ConcertsController < BaseController
      skip_before_action :authenticate_user!, only: [:index, :show, :nearby, :upcoming]
      before_action :require_admin, only: [:create, :update, :destroy]
      before_action :set_concert, only: [:show, :update, :destroy]

      # GET /api/v1/concerts
      def index
        @concerts = Concert.includes(:artist).all

        # Apply filters
        @concerts = @concerts.where(artist_id: params[:artist_id]) if params[:artist_id].present?
        @concerts = @concerts.in_city(params[:city]) if params[:city].present?

        # Date range filter
        if params[:start_date].present? && params[:end_date].present?
          @concerts = @concerts.by_date_range(
            Date.parse(params[:start_date]),
            Date.parse(params[:end_date])
          )
        end

        # Order by date
        @concerts = @concerts.order(:starts_at)

        render json: {
          concerts: @concerts.map { |concert| ConcertSerializer.new(concert).serializable_hash[:data][:attributes] }
        }, status: :ok
      end

      # GET /api/v1/concerts/upcoming
      def upcoming
        @concerts = Concert.includes(:artist).upcoming.order(:starts_at).limit(50)

        render json: {
          concerts: @concerts.map { |concert| ConcertSerializer.new(concert).serializable_hash[:data][:attributes] }
        }, status: :ok
      end

      # GET /api/v1/concerts/nearby?lat=48.8566&lng=2.3522&radius=50
      def nearby
        unless params[:lat].present? && params[:lng].present?
          return render json: {
            error: 'Bad Request',
            message: 'Latitude and longitude are required'
          }, status: :bad_request
        end

        lat = params[:lat].to_f
        lng = params[:lng].to_f
        radius = params[:radius].present? ? params[:radius].to_f : 50

        @concerts = Concert.near([lat, lng], radius, units: :km)
                           .where("starts_at >= ?", Time.current)
                           .order("distance ASC")

        render json: {
          concerts: @concerts.map do |concert|
            serialized = ConcertSerializer.new(concert).serializable_hash[:data][:attributes]
            serialized[:distance] = concert.distance.round(2)
            serialized
          end
        }, status: :ok
      rescue Geocoder::Error => e
        Rails.logger.error("Geocoding error in nearby: #{e.message}")
        render json: {
          error: "Internal Server Error",
          message: "Location service temporarily unavailable"
        }, status: :internal_server_error
      end

      # GET /api/v1/concerts/:id
      def show
        render json: {
          concert: ConcertSerializer.new(@concert).serializable_hash[:data][:attributes]
        }, status: :ok
      end

      # POST /api/v1/concerts
      def create
        @concert = Concert.new(concert_params)

        if @concert.save
          render json: {
            message: 'Concert created successfully',
            concert: ConcertSerializer.new(@concert).serializable_hash[:data][:attributes]
          }, status: :created
        else
          render json: {
            error: 'Concert could not be created',
            message: @concert.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/concerts/:id
      def update
        if @concert.update(concert_params)
          render json: {
            message: 'Concert updated successfully',
            concert: ConcertSerializer.new(@concert).serializable_hash[:data][:attributes]
          }, status: :ok
        else
          render json: {
            error: 'Concert could not be updated',
            message: @concert.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/concerts/:id
      def destroy
        @concert.destroy
        render json: {
          message: 'Concert deleted successfully'
        }, status: :ok
      end

      private

      def set_concert
        @concert = Concert.includes(:artist).find(params[:id])
      end

      def concert_params
        params.require(:concert).permit(
          :artist_id,
          :title,
          :description,
          :starts_at,
          :ends_at,
          :venue_name,
          :venue_address,
          :city,
          :country,
          :latitude,
          :longitude,
          :price,
          :ticket_url
        )
      end
    end
  end
end
