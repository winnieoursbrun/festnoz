# frozen_string_literal: true

class ArtistSerializer
  include JSONAPI::Serializer

  attributes :id, :name, :description, :genre, :image_url, :country, :website, :created_at

  # AudioDB-enriched attributes
  attributes :biography, :music_style, :formed_year, :disbanded_year
  attributes :fanart_url, :banner_url, :logo_url, :thumbnail_url
  attributes :facebook_url, :twitter_handle
  attributes :audiodb_status, :audiodb_enriched_at

  # Spotify-enriched attributes
  attributes :spotify_id, :spotify_url, :popularity

  # Ticketmaster attributes
  attributes :ticketmaster_id, :ticketmaster_url, :ticketmaster_name

  attribute :followers_count do |artist|
    artist.followers.count
  end

  attribute :upcoming_concerts_count do |artist|
    artist.upcoming_concerts.count
  end

  attribute :on_tour do |artist|
    artist.on_tour?
  end

  attribute :social_links do |artist|
    artist.social_links
  end

  attribute :is_enriched do |artist|
    artist.enriched?
  end

  attribute :primary_image_url do |artist|
    artist.primary_image_url
  end
end
