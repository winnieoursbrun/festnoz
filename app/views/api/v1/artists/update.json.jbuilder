json.message 'Artist updated successfully'
json.artist do
  json.partial! 'api/v1/artists/artist', artist: @artist
end
