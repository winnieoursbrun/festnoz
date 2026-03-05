# frozen_string_literal: true

require "test_helper"

class TicketmasterServiceTest < ActiveSupport::TestCase
  setup do
    Rails.application.credentials.stubs(:ticketmaster_api_key).returns("test_api_key")
    @service = TicketmasterService.new
  end

  describe "#search_artist" do
    it "returns artist data from Ticketmaster" do
      body = {
        _embedded: {
          attractions: [
            { id: "tm1", name: "Plantec", url: "https://www.ticketmaster.com/plantec" }
          ]
        }
      }.to_json

      stub_request(:get, /app.ticketmaster.com.*attractions/)
        .to_return(status: 200, body: body, headers: { "Content-Type" => "application/json" })

      service = @service
      results = service.search_artist("Plantec")
      assert_kind_of Hash, results
      assert_kind_of Array, results[:attractions]
      assert_equal "tm1", results[:attractions].first["id"]
    end
  end

  describe "#fetch_and_create_events" do
    it "creates concerts from Ticketmaster events" do
      artist = create(:artist, :with_ticketmaster, ticketmaster_id: "tm1")

      events_body = {
        _embedded: {
          events: [
            {
              id: "evt1",
              name: "Plantec Live",
              url: "https://www.ticketmaster.com/event/1",
              dates: { start: { dateTime: 2.weeks.from_now.iso8601 } },
              _embedded: {
                venues: [
                  {
                    name: "Espace Glenmor",
                    city: { name: "Carhaix" },
                    country: { name: "France" },
                    location: { longitude: "-3.5718", latitude: "48.2773" }
                  }
                ]
              }
            }
          ]
        }
      }.to_json

      stub_request(:get, /app.ticketmaster.com.*events/)
        .to_return(status: 200, body: events_body, headers: { "Content-Type" => "application/json" })

      service = TicketmasterService.new
      result = service.fetch_and_create_events(artist)
      assert result[:created] >= 0
    end
  end
end
