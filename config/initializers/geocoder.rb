# frozen_string_literal: true

Geocoder.configure(
  # Geocoding service configuration
  lookup: :nominatim,

  # Nominatim (OpenStreetMap) specific settings
  nominatim: {
    email: Rails.application.credentials.nominatim_email || "admin@example.com", # Required by Nominatim TOS
    timeout: 5 # seconds
  },

  # HTTP configuration
  timeout: 5, # seconds
  use_https: true,
  http_headers: {
    "User-Agent" => "FestNoz Concert App (Rails 8.1.1)" # Required by Nominatim TOS
  },

  # Rate limiting (Nominatim limit: 1 req/sec)
  always_raise: :all, # Raise exceptions on all errors for better debugging

  # Units and distance calculation
  units: :km, # Matches existing Haversine implementation
  distances: :linear, # Use spherical Earth model (similar to Haversine)

  # Cache configuration (optional but recommended for production)
  cache: Rails.cache,
  cache_prefix: "geocoder:"

  # API key (not needed for Nominatim, but left for future services)
  # api_key: ENV['GEOCODING_API_KEY']
)
