# frozen_string_literal: true

FactoryBot.define do
  factory :concert do
    association :artist
    sequence(:title) { |n| "Concert #{n}" }
    venue_name { "Espace Glenmor" }
    city { "Carhaix" }
    country { "France" }
    starts_at { 1.week.from_now }
    latitude { 48.2773 }
    longitude { -3.5718 }

    trait :upcoming do
      starts_at { 2.weeks.from_now }
      ends_at { 2.weeks.from_now + 3.hours }
    end

    trait :past do
      starts_at { 1.month.ago }
      ends_at { 1.month.ago + 3.hours }
    end

    trait :with_ticket do
      price { 15.00 }
      ticket_url { "https://tickets.example.com" }
    end
  end
end
