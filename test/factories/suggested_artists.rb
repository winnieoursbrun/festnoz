# frozen_string_literal: true
FactoryBot.define do
  factory :suggested_artist do
    association :user
    association :artist
    rank { 1 }
    synced_at { Time.current }
    sequence(:spotify_artist_id) { |n| "spotify_#{n}" }
  end
end
