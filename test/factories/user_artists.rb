# frozen_string_literal: true

FactoryBot.define do
  factory :user_artist do
    association :user
    association :artist
  end
end
