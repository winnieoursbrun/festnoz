# frozen_string_literal: true

class ConcertSerializer
  include JSONAPI::Serializer

  attributes :id,
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
             :ticket_url,
             :ticketmaster_id,
             :ticketmaster_url,
             :created_at

  attribute :artist do |concert|
    {
      id: concert.artist.id,
      name: concert.artist.name,
      genre: concert.artist.genre,
      image_url: concert.artist.image_url,
      primary_image_url: concert.artist.primary_image_url
    }
  end

  attribute :is_past do |concert|
    concert.starts_at < Time.current
  end

  attribute :is_upcoming do |concert|
    concert.starts_at >= Time.current
  end
end
