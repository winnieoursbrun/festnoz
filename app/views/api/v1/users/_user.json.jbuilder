# frozen_string_literal: true

json.id user.id
json.email user.email
json.username user.username
json.admin user.admin
json.created_at user.created_at
json.provider user.provider
json.followed_artists_count user.followed_artists.count
json.spotify_connected user.spotify_authenticated?
