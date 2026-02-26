json.concerts @concerts do |concert|
  json.partial! 'api/v1/concerts/concert', concert: concert
  json.distance concert.distance.round(2)
end
