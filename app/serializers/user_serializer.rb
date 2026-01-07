# frozen_string_literal: true

class UserSerializer
  include JSONAPI::Serializer

  attributes :id, :email, :username, :admin, :created_at, :provider

  attribute :followed_artists_count do |user|
    user.followed_artists.count
  end

  attribute :spotify_connected do |user|
    user.spotify_authenticated?
  end
end
