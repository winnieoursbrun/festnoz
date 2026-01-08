# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

class TicketmasterService
  BASE_URL = "https://app.ticketmaster.com/discovery/v2"

  def initialize
    @api_key = Rails.application.credentials.ticketmaster_api_key
    raise "Ticketmaster API key not configured" if @api_key.blank?
  end

  # Search for artist entity (attraction) in Ticketmaster
  def search_artist(artist_name)
    uri = URI("#{BASE_URL}/attractions.json")
    params = {
      apikey: @api_key,
      keyword: artist_name,
      size: 10,
      locale: "en"
    }

    uri.query = URI.encode_www_form(params.compact)

    request = Net::HTTP::Get.new(uri)
    response = make_request(uri, request)
    parse_attractions_response(response)
  rescue StandardError => e
    Rails.logger.error("Ticketmaster API error searching artist: #{e.message}")
    { attractions: [], error: e.message }
  end

  # Fetch and store artist entity data
  def fetch_and_store_artist(artist)
    result = search_artist(artist.name)

    return { success: false, error: "No attractions found" } if result[:attractions].empty?

    # Get the best matching attraction (first result is usually most relevant)
    attraction = result[:attractions].first

    # Update artist with Ticketmaster data
    artist.update(
      ticketmaster_id: attraction["id"],
      ticketmaster_url: attraction["url"],
      ticketmaster_name: attraction["name"]
    )

    {
      success: true,
      ticketmaster_id: attraction["id"],
      ticketmaster_name: attraction["name"]
    }
  rescue StandardError => e
    Rails.logger.error("Failed to store artist entity: #{e.message}")
    { success: false, error: e.message }
  end

  # Search events by artist name
  def search_events(artist_name, options = {})
    uri = URI("#{BASE_URL}/events.json")
    params = {
      apikey: @api_key,
      keyword: artist_name,
      size: options[:size] || 100,
      sort: "date,asc",
      locale: "*"
    }.merge(options)

    uri.query = URI.encode_www_form(params.compact)

    request = Net::HTTP::Get.new(uri)
    response = make_request(uri, request)
    parse_response(response)
  rescue StandardError => e
    Rails.logger.error("Ticketmaster API error: #{e.message}")
    { events: [], error: e.message }
  end

  # Search events by Ticketmaster artist ID (more accurate)
  def search_events_by_artist_id(ticketmaster_id, options = {})
    uri = URI("#{BASE_URL}/events.json")
    params = {
      apikey: @api_key,
      attractionId: ticketmaster_id,
      size: options[:size] || 100,
      sort: "date,asc",
      locale: "*"
    }.merge(options)

    uri.query = URI.encode_www_form(params.compact)

    request = Net::HTTP::Get.new(uri)
    response = make_request(uri, request)
    parse_response(response)
  rescue StandardError => e
    Rails.logger.error("Ticketmaster API error: #{e.message}")
    { events: [], error: e.message }
  end

  # Fetch events for an artist and create Concert records
  def fetch_and_create_events(artist)
    # Use artist ID if available for more accurate results
    result = if artist.ticketmaster_id.present?
      Rails.logger.info("Fetching events using Ticketmaster artist ID: #{artist.ticketmaster_id}")
      search_events_by_artist_id(artist.ticketmaster_id)
    else
      Rails.logger.info("Fetching events using artist name: #{artist.name}")
      search_events(artist.name)
    end

    return { created: 0, errors: [] } if result[:events].empty?

    created_count = 0
    errors = []

    result[:events].each do |event_data|
      begin
        concert = create_concert_from_event(artist, event_data)
        created_count += 1 if concert
      rescue StandardError => e
        Rails.logger.error("Failed to create concert: #{e.message}")
        errors << { event_id: event_data["id"], error: e.message }
      end
    end

    { created: created_count, errors: errors, total: result[:events].count }
  end

  private

  def create_concert_from_event(artist, event_data)
    # Extract event title
    title = event_data["name"]
    return nil if title.blank?

    # Extract venue information
    venue = event_data.dig("_embedded", "venues", 0) || {}
    venue_name = venue["name"] || "Unknown Venue"
    venue_address = [ venue["address"]&.dig("line1"), venue["address"]&.dig("line2") ].compact.join(", ")
    city = venue.dig("city", "name") || "Unknown City"
    country = venue.dig("country", "name") || "Unknown Country"

    # Extract date and time
    dates = event_data["dates"] || {}
    start_date = dates.dig("start", "dateTime") || dates.dig("start", "localDate")
    return nil if start_date.blank?

    # Parse the start date
    starts_at = parse_event_date(start_date)
    return nil if starts_at.blank?

    # Extract location coordinates
    latitude = venue.dig("location", "latitude")&.to_f
    longitude = venue.dig("location", "longitude")&.to_f

    # Check if concert already exists
    existing_concert = Concert.find_by(
      artist: artist,
      venue_name: venue_name,
      starts_at: starts_at
    )

    return existing_concert if existing_concert

    # Create new concert
    Concert.create!(
      title: title,
      artist: artist,
      venue_name: venue_name,
      venue_address: venue_address.presence,
      city: city,
      country: country,
      starts_at: starts_at,
      latitude: latitude,
      longitude: longitude,
      ticketmaster_id: event_data["id"],
      ticketmaster_url: event_data["url"],
      description: event_data["info"] || event_data["pleaseNote"]
    )
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.warn("Skipping duplicate or invalid concert: #{e.message}")
    nil
  end

  def parse_event_date(date_string)
    # Handle both datetime and date formats
    if date_string.include?("T")
      Time.zone.parse(date_string)
    else
      Date.parse(date_string).to_time
    end
  rescue ArgumentError => e
    Rails.logger.error("Failed to parse date: #{date_string} - #{e.message}")
    nil
  end

  def make_request(uri, request)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 10
    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      raise "Ticketmaster API error: #{response.code} - #{response.body}"
    end

    response
  end

  def parse_response(response)
    data = JSON.parse(response.body)
    p data
    events = data.dig("_embedded", "events") || []

    {
      events: events,
      total: data.dig("page", "totalElements") || 0,
      page: data.dig("page", "number") || 0
    }
  rescue JSON::ParserError => e
    Rails.logger.error("Failed to parse Ticketmaster response: #{e.message}")
    { events: [], error: "Invalid JSON response" }
  end

  def parse_attractions_response(response)
    data = JSON.parse(response.body)
    attractions = data.dig("_embedded", "attractions") || []

    {
      attractions: attractions,
      total: data.dig("page", "totalElements") || 0,
      page: data.dig("page", "number") || 0
    }
  rescue JSON::ParserError => e
    Rails.logger.error("Failed to parse Ticketmaster attractions response: #{e.message}")
    { attractions: [], error: "Invalid JSON response" }
  end
end
