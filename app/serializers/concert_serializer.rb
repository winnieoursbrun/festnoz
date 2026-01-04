# frozen_string_literal: true

class ConcertSerializer
  include JSONAPI::Serializer

  attributes :id,
             :title,
             :description,
             :starts_at,
             :ends_at,
             :venue_name,
             :address,
             :city,
             :country,
             :latitude,
             :longitude,
             :price,
             :ticket_url,
             :created_at

  attribute :artist do |concert|
    {
      id: concert.artist.id,
      name: concert.artist.name,
      genre: concert.artist.genre,
      image_url: concert.artist.image_url
    }
  end

  attribute :is_past do |concert|
    concert.ends_at < Time.current
  end

  attribute :is_upcoming do |concert|
    concert.starts_at >= Time.current
  end
end
