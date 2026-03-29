# frozen_string_literal: true

require "test_helper"

class ArtistTest < ActiveSupport::TestCase
  subject { create(:artist) }

  # Associations
  should have_many(:concerts).dependent(:destroy)
  should have_many(:user_artists).dependent(:destroy)
  should have_many(:followers).through(:user_artists)
  should have_many(:suggested_artists).dependent(:destroy)

  # Validations
  should validate_presence_of(:name)
  should validate_uniqueness_of(:name)
  should validate_presence_of(:genre)

  describe "scopes" do
    it "filters by genre" do
      a1 = create(:artist, genre: "Fest-Noz")
      a2 = create(:artist, genre: "Rock")
      assert_includes Artist.by_genre("Fest-Noz"), a1
      assert_not_includes Artist.by_genre("Fest-Noz"), a2
    end

    it "searches by name case-insensitively" do
      a1 = create(:artist, name: "Plantec")
      a2 = create(:artist, name: "Other Band")
      assert_includes Artist.search_by_name("plante"), a1
      assert_not_includes Artist.search_by_name("plante"), a2
    end

    it "returns needs_enrichment artists" do
      a1 = create(:artist, audiodb_status: nil)
      a2 = create(:artist, audiodb_status: "pending")
      a3 = create(:artist, :enriched)
      assert_includes Artist.needs_enrichment, a1
      assert_includes Artist.needs_enrichment, a2
      assert_not_includes Artist.needs_enrichment, a3
    end
  end

  describe "#enriched?" do
    it "returns true when audiodb_status is enriched" do
      assert create(:artist, :enriched).enriched?
    end

    it "returns false when not enriched" do
      assert_not create(:artist).enriched?
    end
  end

  describe "#follower_count" do
    it "returns count of followers" do
      artist = create(:artist)
      create(:user_artist, artist: artist)
      create(:user_artist, artist: artist)
      assert_equal 2, artist.follower_count
    end
  end

  describe "#social_links" do
    it "returns present links only" do
      artist = create(:artist, website: "https://example.com", twitter_handle: "artist")
      links = artist.social_links
      assert_equal "https://example.com", links[:website]
      assert_includes links[:twitter], "artist"
      assert_nil links[:facebook]
    end
  end
end
