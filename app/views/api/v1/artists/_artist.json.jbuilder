# frozen_string_literal: true

json.id artist.id
json.name artist.name
json.description artist.description
json.genre artist.genre
json.image_url artist.image_url
json.country artist.country
json.website artist.website
json.created_at artist.created_at

# AudioDB-enriched attributes
json.biography artist.biography
json.music_style artist.music_style
json.formed_year artist.formed_year
json.disbanded_year artist.disbanded_year
json.fanart_url artist.fanart_url
json.banner_url artist.banner_url
json.logo_url artist.logo_url
json.thumbnail_url artist.thumbnail_url
json.facebook_url artist.facebook_url
json.twitter_handle artist.twitter_handle
json.audiodb_status artist.audiodb_status
json.audiodb_enriched_at artist.audiodb_enriched_at

# Spotify-enriched attributes
json.spotify_id artist.spotify_id
json.spotify_url artist.spotify_url
json.popularity artist.popularity

# Ticketmaster attributes
json.ticketmaster_id artist.ticketmaster_id
json.ticketmaster_url artist.ticketmaster_url
json.ticketmaster_name artist.ticketmaster_name

# Computed attributes
json.followers_count artist.followers.count
json.upcoming_concerts_count artist.upcoming_concerts.size
json.on_tour artist.on_tour?
json.social_links artist.social_links
json.is_enriched artist.enriched?
json.primary_image_url artist.primary_image_url
