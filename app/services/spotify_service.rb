# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

class SpotifyService
  BASE_URL = "https://api.spotify.com/v1"
  TOKEN_URL = "https://accounts.spotify.com/api/token"

  def initialize(user)
    @user = user
  end

  # Fetch user's top artists from Spotify
  def fetch_top_artists(time_range: "medium_term", limit: 20)
    ensure_valid_token!

    uri = URI("#{BASE_URL}/me/top/artists")
    params = { time_range: time_range, limit: limit }
    uri.query = URI.encode_www_form(params)

    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{@user.spotify_access_token}"

    response = make_request(uri, request)
    JSON.parse(response.body)
  rescue StandardError => e
    Rails.logger.error("Spotify API error: #{e.message}")
    raise
  end

  # Sync top artists to database and create suggestions
  def sync_top_artists_to_suggestions(time_range: "medium_term", limit: 20)
    top_artists_data = fetch_top_artists(time_range: time_range, limit: limit)

    synced_at = Time.current
    suggestions = []

    top_artists_data["items"].each_with_index do |artist_data, index|
      artist = find_or_create_artist(artist_data)
      next unless artist

      suggestion = @user.suggested_artists.find_or_initialize_by(artist: artist)
      suggestion.update(
        spotify_artist_id: artist_data["id"],
        rank: index,
        synced_at: synced_at
      )
      suggestions << suggestion
    end

    # Remove old suggestions that are no longer in top artists
    @user.suggested_artists.where("synced_at < ?", synced_at).destroy_all

    suggestions
  end

  private

  # Ensure the access token is valid, refresh if needed
  def ensure_valid_token!
    return if @user.spotify_access_token.blank?

    if token_expired?
      refresh_access_token!
    end
  end

  # Check if the token is expired
  def token_expired?
    return true if @user.spotify_token_expires_at.blank?
    @user.spotify_token_expires_at < Time.current
  end

  # Refresh the Spotify access token
  def refresh_access_token!
    return unless @user.spotify_refresh_token.present?

    uri = URI(TOKEN_URL)
    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/x-www-form-urlencoded"
    request.basic_auth(
      Rails.application.credentials.spotify_client_id,
      Rails.application.credentials.spotify_client_secret
    )

    request.set_form_data(
      grant_type: "refresh_token",
      refresh_token: @user.spotify_refresh_token
    )

    response = make_request(uri, request)
    token_data = JSON.parse(response.body)

    if token_data["access_token"]
      @user.update_spotify_tokens(
        token_data["access_token"],
        token_data["refresh_token"] || @user.spotify_refresh_token,
        Time.current.to_i + token_data["expires_in"].to_i
      )
    else
      raise "Failed to refresh Spotify token: #{token_data["error"]}"
    end
  rescue StandardError => e
    Rails.logger.error("Token refresh error: #{e.message}")
    raise
  end

  # Find or create an artist from Spotify data
  def find_or_create_artist(artist_data)
    artist = Artist.find_or_initialize_by(spotify_id: artist_data["id"])

    # Use first genre or default to "Unknown" if none provided
    genre = artist_data["genres"]&.first || "Unknown"

    artist.assign_attributes(
      name: artist_data["name"],
      image_url: artist_data["images"]&.first&.dig("url"),
      genre: genre,
      popularity: artist_data["popularity"],
      spotify_url: artist_data["external_urls"]&.dig("spotify")
    )

    artist.save
    artist
  rescue StandardError => e
    Rails.logger.error("Error creating artist #{artist_data["name"]}: #{e.message}")
    nil
  end

  # Make HTTP request with error handling
  def make_request(uri, request)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      raise "Spotify API error: #{response.code} - #{response.body}"
    end

    response
  end
end
