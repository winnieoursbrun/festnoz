# frozen_string_literal: true

require "test_helper"

class AudiodbServiceTest < ActiveSupport::TestCase
  setup do
    @service = AudiodbService.new
    @artist  = create(:artist, name: "Plantec")
  end

  describe "#search_artist" do
    it "returns artist data from AudioDB" do
      body = {
        artists: [
          {
            "idArtist" => "12345",
            "strArtist" => "Plantec",
            "strBiographyEN" => "Breton band",
            "strArtistThumb" => nil,
            "strFacebook" => nil,
            "strTwitter" => nil,
            "strWebsite" => nil
          }
        ]
      }.to_json

      stub_request(:get, /theaudiodb.com.*search\.php/)
        .to_return(status: 200, body: body, headers: { "Content-Type" => "application/json" })

      result = @service.search_artist("Plantec")
      assert_equal "12345", result["idArtist"]
    end

    it "returns nil when artist not found" do
      stub_request(:get, /theaudiodb.com.*search\.php/)
        .to_return(status: 200, body: { artists: nil }.to_json, headers: { "Content-Type" => "application/json" })

      result = @service.search_artist("UnknownArtist")
      assert_nil result
    end
  end

  describe "#enrich_artist" do
    it "updates artist with AudioDB data" do
      body = {
        artists: [
          {
            "idArtist" => "12345",
            "strArtist" => "Plantec",
            "strBiographyEN" => "A famous Breton punk folk band",
            "strArtistThumb" => "http://img.example.com/thumb.jpg",
            "strFacebook" => nil,
            "strTwitter" => nil,
            "strWebsite" => nil
          }
        ]
      }.to_json

      stub_request(:get, /theaudiodb.com/)
        .to_return(status: 200, body: body, headers: { "Content-Type" => "application/json" })

      @service.enrich_artist(@artist)
      @artist.reload

      assert_equal "enriched", @artist.audiodb_status
      assert_equal "A famous Breton punk folk band", @artist.biography
    end

    it "marks artist as not_found when AudioDB has no data" do
      stub_request(:get, /theaudiodb.com/)
        .to_return(status: 200, body: { artists: nil }.to_json, headers: { "Content-Type" => "application/json" })

      @service.enrich_artist(@artist)
      @artist.reload

      assert_equal "not_found", @artist.audiodb_status
    end
  end
end
