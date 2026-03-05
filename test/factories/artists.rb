# frozen_string_literal: true

FactoryBot.define do
  factory :artist do
    sequence(:name) { |n| "Artist #{n}" }
    genre { "Fest-Noz" }
    description { "A great Breton band" }
    audiodb_status { nil }

    trait :enriched do
      audiodb_status { "enriched" }
      audiodb_enriched_at { 1.day.ago }
      biography { "Enriched biography" }
    end

    trait :needs_enrichment do
      audiodb_status { nil }
    end

    trait :with_spotify do
      sequence(:spotify_id) { |n| "spotify_artist_#{n}" }
    end

    trait :with_ticketmaster do
      sequence(:ticketmaster_id) { |n| "tm_#{n}" }
      ticketmaster_name { "TM Artist" }
    end
  end
end
