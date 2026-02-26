json.message 'Artist created successfully'
json.artist do
  json.partial! 'api/v1/artists/artist', artist: @artist
end
