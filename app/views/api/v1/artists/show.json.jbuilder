json.artist do
  json.partial! "api/v1/artists/artist", artist: @artist
end
json.is_following @is_following
json.enrichment_status @artist.audiodb_status
