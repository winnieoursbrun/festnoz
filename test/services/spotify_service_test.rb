# frozen_string_literal: true

require "test_helper"

class SpotifyServiceTest < ActiveSupport::TestCase
  setup do
    @service = SpotifyService.new
    stub_request(:post, "https://accounts.spotify.com/api/token")
      .to_return(
        status: 200,
        body: { access_token: "test_token", expires_in: 3600 }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
  end

  describe "#search_artists" do
    it "searches and returns artists from Spotify API" do
      response_body = {
        artists: {
          items: [
            { id: "sp1", name: "Plantec", genres: [ "Breton" ], images: [], followers: { total: 100 }, popularity: 50 }
          ]
        }
      }.to_json

      stub_request(:get, /api.spotify.com\/v1\/search/)
        .to_return(status: 200, body: response_body, headers: { "Content-Type" => "application/json" })

      results = @service.search_artists("Plantec", limit: 5)
      assert_kind_of Array, results
      assert_equal "Plantec", results.first["name"]
    end

    it "raises on Spotify error" do
      stub_request(:get, /api.spotify.com\/v1\/search/)
        .to_return(status: 500, body: "Server Error")

      assert_raises(RuntimeError) { @service.search_artists("Unknown", limit: 5) }
    end
  end

  describe "#import_artist" do
    it "creates an artist from Spotify data" do
      artist_body = {
        id: "spot1",
        name: "New Breton Artist",
        genres: [ "breton" ],
        images: [ { url: "http://img.example.com/1.jpg" } ],
        followers: { total: 200 },
        popularity: 60,
        external_urls: { spotify: "https://open.spotify.com/artist/spot1" }
      }.to_json

      stub_request(:get, /api.spotify.com\/v1\/artists\/spot1/)
        .to_return(status: 200, body: artist_body, headers: { "Content-Type" => "application/json" })

      assert_difference "Artist.count", 1 do
        artist = @service.import_artist("spot1")
        assert_equal "New Breton Artist", artist.name
        assert_equal "spot1", artist.spotify_id
      end
    end

    it "returns existing artist if spotify_id matches" do
      existing = create(:artist, :with_spotify, spotify_id: "existing_id", name: "Existing Artist")
      artist_body = {
        id: "existing_id",
        name: "Existing Artist",
        genres: [ "breton" ],
        images: [],
        followers: { total: 50 },
        popularity: 30,
        external_urls: { spotify: "https://open.spotify.com/artist/existing_id" }
      }.to_json

      stub_request(:get, /api.spotify.com\/v1\/artists\/existing_id/)
        .to_return(status: 200, body: artist_body, headers: { "Content-Type" => "application/json" })

      assert_no_difference "Artist.count" do
        artist = @service.import_artist("existing_id")
        assert_equal existing.id, artist.id
      end
    end
  end
end
