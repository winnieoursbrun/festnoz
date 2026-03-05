# frozen_string_literal: true

require "test_helper"

class ConcertTest < ActiveSupport::TestCase
  # Associations
  should belong_to(:artist)

  # Validations
  should validate_presence_of(:title)
  should validate_presence_of(:venue_name)
  should validate_presence_of(:city)
  should validate_presence_of(:country)
  should validate_presence_of(:starts_at)

  describe "scopes" do
    it "returns upcoming concerts" do
      upcoming = create(:concert, :upcoming)
      past = create(:concert, :past)
      assert_includes Concert.upcoming, upcoming
      assert_not_includes Concert.upcoming, past
    end

    it "returns past concerts" do
      upcoming = create(:concert, :upcoming)
      past = create(:concert, :past)
      assert_includes Concert.past, past
      assert_not_includes Concert.past, upcoming
    end

    it "filters by city case-insensitively" do
      c1 = create(:concert, city: "Carhaix")
      c2 = create(:concert, city: "Rennes")
      assert_includes Concert.in_city("carhaix"), c1
      assert_not_includes Concert.in_city("carhaix"), c2
    end
  end

  describe "ends_at validation" do
    it "is valid when ends_at is after starts_at" do
      concert = build(:concert, starts_at: 1.day.from_now, ends_at: 2.days.from_now)
      assert concert.valid?
    end

    it "is invalid when ends_at is before starts_at" do
      concert = build(:concert, starts_at: 2.days.from_now, ends_at: 1.day.from_now)
      assert_not concert.valid?
      assert_includes concert.errors[:ends_at], "must be after start time"
    end
  end

  describe "#full_address" do
    it "combines venue, city, country" do
      concert = build(:concert, venue_name: "Salle Glenmor", venue_address: "1 Rue Test", city: "Carhaix", country: "France")
      assert_includes concert.full_address, "Carhaix"
      assert_includes concert.full_address, "France"
    end
  end
end
