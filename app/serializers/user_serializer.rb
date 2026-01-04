# frozen_string_literal: true

class UserSerializer
  include JSONAPI::Serializer

  attributes :id, :email, :username, :admin, :created_at

  attribute :followed_artists_count do |user|
    user.followed_artists.count
  end
end
