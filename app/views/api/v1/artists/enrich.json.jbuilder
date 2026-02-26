json.message @message
json.artist do
  json.partial! 'api/v1/artists/artist', artist: @artist
end
