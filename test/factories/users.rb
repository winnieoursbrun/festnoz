# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:username) { |n| "user#{n}" }
    password { "password123" }
    password_confirmation { "password123" }
    admin { false }
    jti { SecureRandom.uuid }

    trait :admin do
      admin { true }
    end

    trait :spotify_connected do
      provider { "spotify" }
      uid { "spotify_uid_#{SecureRandom.hex(8)}" }
      spotify_access_token { "tok_#{SecureRandom.hex(16)}" }
      spotify_refresh_token { "ref_#{SecureRandom.hex(16)}" }
      spotify_token_expires_at { 1.hour.from_now }
    end
  end
end
