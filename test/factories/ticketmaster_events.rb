# frozen_string_literal: true

FactoryBot.define do
  factory :ticketmaster_event do
    association :concert
    artist { concert.artist }

    sequence(:ticketmaster_event_id) { |n| "tm_event_#{n}" }
    name { concert.title }
    event_url { "https://www.ticketmaster.com/event/#{ticketmaster_event_id}" }
    locale { "en-us" }
    status_code { "onsale" }
    price_min { 10.00 }
    price_max { 20.00 }
    price_currency { "EUR" }
    price_type { "standard" }
    starts_at { concert.starts_at }
    last_synced_at { Time.current }
    payload { {} }
  end
end
