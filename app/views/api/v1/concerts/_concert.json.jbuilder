# frozen_string_literal: true

json.id concert.id
json.title concert.title
json.description concert.description
json.starts_at concert.starts_at
json.ends_at concert.ends_at
json.venue_name concert.venue_name
json.venue_address concert.venue_address
json.city concert.city
json.country concert.country
json.latitude concert.latitude
json.longitude concert.longitude
json.price concert.price
json.ticket_url concert.ticket_url
json.ticketmaster_id concert.ticketmaster_id
json.ticketmaster_url concert.ticketmaster_url
json.created_at concert.created_at

json.artist do
  json.id concert.artist.id
  json.name concert.artist.name
  json.genre concert.artist.genre
  json.image_url concert.artist.image_url
  json.primary_image_url concert.artist.primary_image_url
end

json.is_past concert.starts_at < Time.current
json.is_upcoming concert.starts_at >= Time.current
