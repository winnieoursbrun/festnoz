json.message 'Concert created successfully'
json.concert do
  json.partial! 'api/v1/concerts/concert', concert: @concert
end
