# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

class TicketmasterService
  BASE_URL = "https://app.ticketmaster.com/discovery/v2"
  EU_BASE_URL = "https://app.ticketmaster.eu/mfxapi/v2"

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

  # Fetch full event details (includes complete priceRanges)
  def fetch_event_details(ticketmaster_event_id, options = {})
    # Prefer the EU endpoint when a domain is configured.
    if ticketmaster_eu_domain.present?
      uri = URI("#{EU_BASE_URL}/events/#{ticketmaster_event_id}")
      params = {
        domain: ticketmaster_eu_domain,
        lang: options[:lang] || ticketmaster_eu_lang
      }
      uri.query = URI.encode_www_form(params.compact)

      request = Net::HTTP::Get.new(uri)
      request["Accept"] = "application/json"

      response = make_request(uri, request)
      details = parse_event_details_response(response)
      return details if details.present?
    end

    # Fallback to Discovery API event details for non-EU ids/markets.
    uri = URI("#{BASE_URL}/events/#{ticketmaster_event_id}.json")
    params = {
      apikey: @api_key,
      locale: options[:locale] || "*"
    }

    uri.query = URI.encode_www_form(params.compact)

    request = Net::HTTP::Get.new(uri)
    response = make_request(uri, request)
    parse_event_details_response(response)
  rescue StandardError => e
    Rails.logger.warn("Ticketmaster event details fetch failed for #{ticketmaster_event_id}: #{e.message}")
    nil
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

    return { created: 0, errors: [], total: 0 } if result[:events].empty?

    created_count = 0
    errors = []

    result[:events].each do |event_data|
      begin
        event_details = fetch_event_details(event_data["id"])
        concert, created = create_concert_from_event(artist, event_data, event_details)
        upsert_ticketmaster_event(artist, concert, event_data, event_details) if concert.present?
        created_count += 1 if created
      rescue StandardError => e
        Rails.logger.error("Failed to create concert: #{e.message}")
        errors << { event_id: event_data["id"], error: e.message }
      end
    end

    { created: created_count, errors: errors, total: result[:events].count }
  end

  private

  def create_concert_from_event(artist, event_data, event_details = nil)
    source_data = event_details || event_data

    # Extract event title
    title = source_data["name"] || event_data["name"]
    return nil if title.blank?

    # Extract venue information
    venue = source_data.dig("_embedded", "venues", 0) || event_data.dig("_embedded", "venues", 0) || {}
    venue_name = venue["name"] || "Unknown Venue"
    venue_address = [ venue["address"]&.dig("line1"), venue["address"]&.dig("line2") ].compact.join(", ")
    city = venue.dig("city", "name") || "Unknown City"
    country = venue.dig("country", "name") || "Unknown Country"

    # Extract date and time
    dates = source_data["dates"] || event_data["dates"] || {}
    start_date = dates.dig("start", "dateTime") || dates.dig("start", "localDate")
    return nil if start_date.blank?

    # Parse the start date
    starts_at = parse_event_date(start_date)
    return nil if starts_at.blank?

    # Extract location coordinates
    latitude = venue.dig("location", "latitude")&.to_f
    longitude = venue.dig("location", "longitude")&.to_f
    price_data = extract_price_range(source_data)

    attributes = {
      title: title,
      artist: artist,
      venue_name: venue_name,
      city: city,
      country: country,
      starts_at: starts_at
    }

    attributes[:venue_address] = venue_address if venue_address.present?

    description = source_data["info"] || source_data["pleaseNote"] || event_data["info"] || event_data["pleaseNote"]
    attributes[:description] = description if description.present?

    attributes[:latitude] = latitude if latitude.present?
    attributes[:longitude] = longitude if longitude.present?

    if price_data
      attributes[:price] = price_data[:min]
      attributes[:price_currency] = price_data[:currency] if price_data[:currency].present?
    end

    # Check if concert already exists
    existing_ticketmaster_event = TicketmasterEvent.find_by(ticketmaster_event_id: event_data["id"])
    existing_concert = existing_ticketmaster_event&.concert
    existing_concert ||= Concert.find_by(
      artist: artist,
      venue_name: venue_name,
      starts_at: starts_at
    )

    if existing_concert
      existing_concert.update!(attributes.except(:artist))
      return [ existing_concert, false ]
    end

    # Create new concert
    [ Concert.create!(attributes), true ]
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.warn("Skipping duplicate or invalid concert: #{e.message}")
    [ nil, false ]
  end

  def upsert_ticketmaster_event(artist, concert, event_data, event_details)
    details = event_details || event_data
    price_data = extract_price_range(details)

    starts_at = parse_optional_datetime(details.dig("dates", "start", "dateTime")) ||
      parse_optional_datetime(details.dig("dates", "start", "localDate"))

    ticketmaster_event = TicketmasterEvent.find_or_initialize_by(ticketmaster_event_id: event_data["id"])
    ticketmaster_event.assign_attributes(
      concert: concert,
      artist: artist,
      ticketmaster_event_id: event_data["id"],
      name: details["name"] || event_data["name"],
      event_url: details["url"] || event_data["url"],
      locale: details["locale"],
      status_code: details.dig("dates", "status", "code"),
      price_min: price_data&.dig(:min),
      price_max: price_data&.dig(:max),
      price_currency: price_data&.dig(:currency),
      price_type: price_data&.dig(:type),
      starts_at: starts_at,
      sales_start_at: parse_optional_datetime(details.dig("sales", "public", "startDateTime")),
      sales_end_at: parse_optional_datetime(details.dig("sales", "public", "endDateTime")),
      info: details["info"],
      please_note: details["pleaseNote"],
      payload: details,
      last_synced_at: Time.current
    )
    ticketmaster_event.save!
  end

  def extract_price_range(event_data)
    price_ranges = event_data["priceRanges"]
    return nil unless price_ranges.is_a?(Array) && price_ranges.any?

    ranges_with_min = price_ranges.select { |range| range["min"].present? }
    return nil if ranges_with_min.empty?

    standard_ranges = ranges_with_min.select { |range| range["type"].to_s.casecmp("standard").zero? }
    candidate_ranges = standard_ranges.presence || ranges_with_min

    selected_price_range = candidate_ranges.min_by { |range| range["min"].to_d }
    return nil unless selected_price_range

    {
      min: selected_price_range["min"],
      max: selected_price_range["max"],
      currency: selected_price_range["currency"],
      type: selected_price_range["type"]
    }
  end

  def parse_optional_datetime(value)
    return nil if value.blank?

    parse_event_date(value)
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

  def parse_event_details_response(response)
    data = JSON.parse(response.body)
    normalize_event_details(data)
  rescue JSON::ParserError => e
    Rails.logger.error("Failed to parse Ticketmaster event details response: #{e.message}")
    nil
  end

  def normalize_event_details(data)
    return data unless data.is_a?(Hash) && data["events"].is_a?(Array)

    eu_event = data["events"].first
    return nil unless eu_event.is_a?(Hash)

    {
      "id" => eu_event["id"],
      "name" => eu_event["name"],
      "url" => eu_event["url"],
      "locale" => eu_event["lang"],
      "info" => eu_event["description"],
      "dates" => {
        "start" => {
          "dateTime" => eu_event.dig("eventdate", "value") || eu_event["local_event_date"]
        },
        "status" => {
          "code" => map_eu_status(eu_event["properties"])
        }
      },
      "sales" => {
        "public" => {
          "startDateTime" => eu_event.dig("onsale", "value"),
          "endDateTime" => eu_event.dig("offsale", "value")
        }
      },
      "_embedded" => {
        "venues" => [ map_eu_venue(eu_event["venue"]) ]
      },
      "priceRanges" => map_eu_price_ranges(eu_event)
    }
  end

  def map_eu_status(properties)
    return nil unless properties.is_a?(Hash)
    return "cancelled" if properties["cancelled"]
    return "offsale" if properties["sold_out"]

    "onsale"
  end

  def map_eu_venue(venue)
    venue ||= {}
    address = venue.dig("location", "address") || {}

    {
      "name" => venue["name"],
      "address" => {
        "line1" => address["address"]
      },
      "city" => {
        "name" => address["city"]
      },
      "country" => {
        "name" => address["country"]
      },
      "location" => {
        "longitude" => address["long"],
        "latitude" => address["lat"]
      }
    }
  end

  def map_eu_price_ranges(eu_event)
    currency = eu_event["currency"]
    price_ranges = eu_event["price_ranges"] || {}

    including_fees = price_ranges["including_ticket_fees"]
    excluding_fees = price_ranges["excluding_ticket_fees"]

    ranges = []

    if including_fees.present? && including_fees["min"].present?
      ranges << {
        "type" => "standard",
        "currency" => currency,
        "min" => including_fees["min"],
        "max" => including_fees["max"]
      }
    end

    if excluding_fees.present? && excluding_fees["min"].present?
      ranges << {
        "type" => "face_value",
        "currency" => currency,
        "min" => excluding_fees["min"],
        "max" => excluding_fees["max"]
      }
    end

    ranges
  end

  def ticketmaster_eu_domain
    Rails.application.credentials.ticketmaster_eu_domain
  end

  def ticketmaster_eu_lang
    Rails.application.credentials.ticketmaster_eu_lang || "en-gb"
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
