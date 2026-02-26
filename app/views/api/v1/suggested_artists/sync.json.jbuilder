json.message @message
json.count @suggested_artists.count
json.data @suggested_artists do |sa|
  json.id sa.id
  json.rank sa.rank
  json.synced_at sa.synced_at
  json.artist do
    json.partial! 'api/v1/artists/artist', artist: sa.artist
  end
end
