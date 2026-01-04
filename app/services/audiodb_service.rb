# frozen_string_literal: true

require "net/http"
require "json"

class AudiodbService
  BASE_URL = "https://www.theaudiodb.com/api/v1/json/2"

  # Rate limiting: 30 requests/minute = 2 seconds between requests minimum
  RATE_LIMIT_DELAY = 2

  class Error < StandardError; end
  class RateLimitError < Error; end
  class NotFoundError < Error; end
  class ApiError < Error; end
  class TimeoutError < Error; end

  def initialize
    @last_request_at = nil
  end

  # Search for an artist by name
  # Returns parsed artist data hash or nil if not found
  def search_artist(artist_name)
    return nil if artist_name.blank?

    response = make_request("/search.php", s: artist_name)
    artists = response["artists"]

    artists&.first
  rescue NotFoundError
    nil
  end

  # Lookup artist by TheAudioDB ID (more reliable than name search)
  def lookup_artist(audiodb_id)
    return nil if audiodb_id.blank?

    response = make_request("/artist.php", i: audiodb_id)
    artists = response["artists"]

    artists&.first
  rescue NotFoundError
    nil
  end

  # Enrich an Artist record with TheAudioDB data
  # Returns true if enrichment succeeded, false otherwise
  def enrich_artist(artist)
    # First try lookup by ID if we have it, otherwise search by name
    audiodb_data = if artist.audiodb_id.present?
                     lookup_artist(artist.audiodb_id)
                   else
                     search_artist(artist.name)
                   end

    if audiodb_data.nil?
      artist.update(audiodb_status: "not_found", audiodb_enriched_at: Time.current)
      return false
    end

    update_artist_from_audiodb(artist, audiodb_data)
    true
  rescue RateLimitError
    artist.update(audiodb_status: "rate_limited")
    raise
  rescue Error => e
    artist.update(audiodb_status: "failed")
    Rails.logger.error("AudioDB enrichment failed for artist #{artist.id}: #{e.message}")
    false
  end

  private

  def make_request(endpoint, params = {})
    enforce_rate_limit

    uri = URI("#{BASE_URL}#{endpoint}")
    uri.query = URI.encode_www_form(params)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 5
    http.read_timeout = 10

    request = Net::HTTP::Get.new(uri)
    response = http.request(request)
    @last_request_at = Time.current

    handle_response(response)
  rescue Net::OpenTimeout, Net::ReadTimeout => e
    raise TimeoutError, "Request timed out: #{e.message}"
  rescue SocketError, Errno::ECONNREFUSED => e
    raise ApiError, "Connection failed: #{e.message}"
  end

  def handle_response(response)
    case response.code.to_i
    when 200
      body = JSON.parse(response.body)
      # AudioDB returns null artists array when not found
      raise NotFoundError, "Artist not found" if body["artists"].nil?
      body
    when 429
      raise RateLimitError, "Rate limit exceeded - try again later"
    when 404
      raise NotFoundError, "Artist not found"
    when 500..599
      raise ApiError, "TheAudioDB server error (#{response.code})"
    else
      raise ApiError, "Unexpected response: #{response.code}"
    end
  end

  def enforce_rate_limit
    return unless @last_request_at

    elapsed = Time.current - @last_request_at
    if elapsed < RATE_LIMIT_DELAY
      sleep(RATE_LIMIT_DELAY - elapsed)
    end
  end

  def update_artist_from_audiodb(artist, data)
    attributes = {
      audiodb_id: data["idArtist"],
      audiodb_status: "enriched",
      audiodb_enriched_at: Time.current
    }

    # Only update fields that are blank in our database (preserve manual edits)
    attributes[:biography] = data["strBiographyEN"] if artist.biography.blank? && data["strBiographyEN"].present?
    attributes[:image_url] = data["strArtistThumb"] if artist.image_url.blank? && data["strArtistThumb"].present?
    attributes[:fanart_url] = data["strArtistFanart"] if data["strArtistFanart"].present?
    attributes[:banner_url] = data["strArtistBanner"] if data["strArtistBanner"].present?
    attributes[:logo_url] = data["strArtistLogo"] if data["strArtistLogo"].present?
    attributes[:thumbnail_url] = data["strArtistThumb"] if data["strArtistThumb"].present?
    attributes[:genre] = data["strGenre"] if artist.genre.blank? && data["strGenre"].present?
    attributes[:music_style] = data["strStyle"] if data["strStyle"].present?
    attributes[:country] = data["strCountry"] if artist.country.blank? && data["strCountry"].present?
    attributes[:website] = data["strWebsite"] if artist.website.blank? && data["strWebsite"].present?
    attributes[:facebook_url] = normalize_facebook_url(data["strFacebook"]) if data["strFacebook"].present?
    attributes[:twitter_handle] = normalize_twitter_handle(data["strTwitter"]) if data["strTwitter"].present?
    attributes[:formed_year] = data["intFormedYear"].to_i if data["intFormedYear"].present? && data["intFormedYear"].to_i > 0
    attributes[:disbanded_year] = data["intDiedYear"].to_i if data["intDiedYear"].present? && data["intDiedYear"].to_i > 0

    artist.update!(attributes)
  end

  def normalize_facebook_url(facebook)
    return nil if facebook.blank?
    facebook.start_with?("http") ? facebook : "https://facebook.com/#{facebook}"
  end

  def normalize_twitter_handle(twitter)
    return nil if twitter.blank?
    twitter.delete_prefix("@")
  end
end
