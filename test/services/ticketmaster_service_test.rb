# frozen_string_literal: true

require "test_helper"

class TicketmasterServiceTest < ActiveSupport::TestCase
  setup do
    Rails.application.credentials.stubs(:ticketmaster_api_key).returns("test_api_key")
    Rails.application.credentials.stubs(:ticketmaster_eu_domain).returns(nil)
    Rails.application.credentials.stubs(:ticketmaster_eu_lang).returns(nil)
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
      starts_at = 2.weeks.from_now.change(usec: 0)

      events_body = {
        _embedded: {
          events: [
            {
              id: "evt1",
              name: "Plantec Live",
              url: "https://www.ticketmaster.com/event/1",
              dates: { start: { dateTime: starts_at.iso8601 } },
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

      event_details_body = {
        id: "evt1",
        name: "Plantec Live",
        url: "https://www.ticketmaster.com/event/1",
        locale: "fr-fr",
        priceRanges: [ { type: "standard", currency: "EUR", min: 19.5, max: 39.9 } ],
        dates: {
          start: { dateTime: starts_at.iso8601 },
          status: { code: "onsale" }
        },
        sales: {
          public: {
            startDateTime: 1.day.ago.iso8601,
            endDateTime: 1.week.from_now.iso8601
          }
        },
        info: "Main room"
      }.to_json

      stub_request(:get, %r{app.ticketmaster.com/discovery/v2/events\.json})
        .to_return(status: 200, body: events_body, headers: { "Content-Type" => "application/json" })

      stub_request(:get, %r{app.ticketmaster.com/discovery/v2/events/evt1\.json})
        .to_return(status: 200, body: event_details_body, headers: { "Content-Type" => "application/json" })

      service = TicketmasterService.new
      result = service.fetch_and_create_events(artist)

      assert_equal 1, result[:created]
      tm_event = TicketmasterEvent.find_by(ticketmaster_event_id: "evt1")
      concert = tm_event&.concert
      assert_not_nil concert
      assert_equal BigDecimal("19.5"), concert.price
      assert_equal "EUR", concert.price_currency

      assert_not_nil tm_event
      assert_equal concert.id, tm_event.concert_id
      assert_equal artist.id, tm_event.artist_id
      assert_equal BigDecimal("19.5"), tm_event.price_min
      assert_equal BigDecimal("39.9"), tm_event.price_max
      assert_equal "EUR", tm_event.price_currency
      assert_equal "standard", tm_event.price_type
      assert_equal "onsale", tm_event.status_code
    end

    it "updates existing concerts with latest Ticketmaster price data" do
      artist = create(:artist, :with_ticketmaster, ticketmaster_id: "tm1")
      starts_at = 2.weeks.from_now.change(usec: 0)
      concert = create(
        :concert,
        artist: artist,
        venue_name: "Espace Glenmor",
        starts_at: starts_at,
        price: nil,
        price_currency: "EUR"
      )
      create(:ticketmaster_event, concert: concert, artist: artist, ticketmaster_event_id: "evt2")

      events_body = {
        _embedded: {
          events: [
            {
              id: "evt2",
              name: "Plantec Live Updated",
              url: "https://www.ticketmaster.com/event/2",
              dates: { start: { dateTime: starts_at.iso8601 } },
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

      event_details_body = {
        id: "evt2",
        name: "Plantec Live Updated",
        url: "https://www.ticketmaster.com/event/2",
        priceRanges: [ { currency: "USD", min: 30, max: 65 } ],
        dates: { start: { dateTime: starts_at.iso8601 }, status: { code: "onsale" } }
      }.to_json

      stub_request(:get, %r{app.ticketmaster.com/discovery/v2/events\.json})
        .to_return(status: 200, body: events_body, headers: { "Content-Type" => "application/json" })

      stub_request(:get, %r{app.ticketmaster.com/discovery/v2/events/evt2\.json})
        .to_return(status: 200, body: event_details_body, headers: { "Content-Type" => "application/json" })

      result = TicketmasterService.new.fetch_and_create_events(artist)

      assert_equal 0, result[:created]
      assert_equal 1, artist.concerts.count

      concert.reload
      assert_equal "Plantec Live Updated", concert.title
      assert_equal BigDecimal("30"), concert.price
      assert_equal "USD", concert.price_currency

      tm_event = TicketmasterEvent.find_by(ticketmaster_event_id: "evt2")
      assert_not_nil tm_event
      assert_equal BigDecimal("30"), tm_event.price_min
      assert_equal BigDecimal("65"), tm_event.price_max
      assert_equal "USD", tm_event.price_currency
    end

    it "selects the lowest standard minimum price when multiple ranges exist" do
      artist = create(:artist, :with_ticketmaster, ticketmaster_id: "tm1")
      starts_at = 3.weeks.from_now.change(usec: 0)

      events_body = {
        _embedded: {
          events: [
            {
              id: "evt3",
              name: "Plantec Pricing",
              url: "https://www.ticketmaster.com/event/3",
              dates: { start: { dateTime: starts_at.iso8601 } },
              _embedded: {
                venues: [
                  {
                    name: "Le Liberté",
                    city: { name: "Rennes" },
                    country: { name: "France" },
                    location: { longitude: "-1.6800", latitude: "48.1100" }
                  }
                ]
              }
            }
          ]
        }
      }.to_json

      event_details_body = {
        id: "evt3",
        name: "Plantec Pricing",
        url: "https://www.ticketmaster.com/event/3",
        priceRanges: [
          { type: "vip", currency: "EUR", min: 120 },
          { type: "standard", currency: "EUR", min: 45.5 },
          { type: "standard", currency: "EUR", min: 29.9 }
        ],
        dates: { start: { dateTime: starts_at.iso8601 } }
      }.to_json

      stub_request(:get, %r{app.ticketmaster.com/discovery/v2/events\.json})
        .to_return(status: 200, body: events_body, headers: { "Content-Type" => "application/json" })

      stub_request(:get, %r{app.ticketmaster.com/discovery/v2/events/evt3\.json})
        .to_return(status: 200, body: event_details_body, headers: { "Content-Type" => "application/json" })

      result = TicketmasterService.new.fetch_and_create_events(artist)

      assert_equal 1, result[:created]
      tm_event = TicketmasterEvent.find_by(ticketmaster_event_id: "evt3")
      concert = tm_event&.concert
      assert_equal BigDecimal("29.9"), concert.price
      assert_equal "EUR", concert.price_currency

      assert_not_nil tm_event
      assert_equal BigDecimal("29.9"), tm_event.price_min
    end

    it "returns a stable payload shape when no events are found" do
      artist = create(:artist, :with_ticketmaster, ticketmaster_id: "tm1")

      empty_body = {
        page: {
          size: 0,
          totalElements: 0,
          totalPages: 0,
          number: 0
        }
      }.to_json

      stub_request(:get, %r{app.ticketmaster.com/discovery/v2/events\.json})
        .to_return(status: 200, body: empty_body, headers: { "Content-Type" => "application/json" })

      result = TicketmasterService.new.fetch_and_create_events(artist)

      assert_equal({ created: 0, errors: [], total: 0 }, result)
    end

    it "falls back to search payload when event details endpoint fails" do
      artist = create(:artist, :with_ticketmaster, ticketmaster_id: "tm1")
      starts_at = 10.days.from_now.change(usec: 0)

      events_body = {
        _embedded: {
          events: [
            {
              id: "evt4",
              name: "Fallback Event",
              url: "https://www.ticketmaster.com/event/4",
              priceRanges: [ { type: "standard", currency: "GBP", min: 12, max: 20 } ],
              dates: { start: { dateTime: starts_at.iso8601 } },
              _embedded: {
                venues: [
                  {
                    name: "SSE Arena",
                    city: { name: "Belfast" },
                    country: { name: "United Kingdom" },
                    location: { longitude: "-5.9100", latitude: "54.6000" }
                  }
                ]
              }
            }
          ]
        }
      }.to_json

      stub_request(:get, %r{app.ticketmaster.com/discovery/v2/events\.json})
        .to_return(status: 200, body: events_body, headers: { "Content-Type" => "application/json" })

      stub_request(:get, %r{app.ticketmaster.com/discovery/v2/events/evt4\.json})
        .to_return(status: 500, body: "{}", headers: { "Content-Type" => "application/json" })

      result = TicketmasterService.new.fetch_and_create_events(artist)

      assert_equal 1, result[:created]
      tm_event = TicketmasterEvent.find_by(ticketmaster_event_id: "evt4")
      concert = tm_event&.concert
      assert_equal BigDecimal("12"), concert.price
      assert_equal "GBP", concert.price_currency

      assert_not_nil tm_event
      assert_equal BigDecimal("12"), tm_event.price_min
      assert_equal "GBP", tm_event.price_currency
    end

    it "uses EU event details endpoint when a domain is configured" do
      Rails.application.credentials.stubs(:ticketmaster_eu_domain).returns("norway")
      Rails.application.credentials.stubs(:ticketmaster_eu_lang).returns("no-no")

      artist = create(:artist, :with_ticketmaster, ticketmaster_id: "tm1")
      starts_at = 10.days.from_now.change(usec: 0)

      events_body = {
        _embedded: {
          events: [
            {
              id: "449621",
              name: "R5",
              url: "https://www.ticketmaster.com/event/449621",
              dates: { start: { dateTime: starts_at.iso8601 } },
              _embedded: {
                venues: [
                  {
                    name: "O2 Shepherd's Bush Empire",
                    city: { name: "London" },
                    country: { name: "United Kingdom" },
                    location: { longitude: "-0.22312", latitude: "51.50326" }
                  }
                ]
              }
            }
          ]
        }
      }.to_json

      eu_details_body = {
        events: [
          {
            id: "449621",
            domain: "norway",
            name: "R5",
            url: "http://www.ticketweb.co.uk/checkout/event.php?eventId=IEH1310Y",
            eventdate: {
              format: "datetime",
              value: starts_at.iso8601
            },
            onsale: {
              format: "datetime",
              value: 1.day.ago.iso8601
            },
            offsale: {
              format: "datetime",
              value: 1.day.from_now.iso8601
            },
            properties: {
              cancelled: false,
              sold_out: false
            },
            venue: {
              id: "9497",
              name: "O2 Shepherd's Bush Empire",
              location: {
                address: {
                  address: "Shepherds Bush Green, Shepherds Bush",
                  city: "London",
                  country: "United Kingdom",
                  long: -0.22312,
                  lat: 51.50326
                }
              }
            },
            price_ranges: {
              excluding_ticket_fees: {
                min: 18.5,
                max: 18.5
              },
              including_ticket_fees: {
                min: 20.81,
                max: 20.81
              }
            },
            currency: "GBP"
          }
        ]
      }.to_json

      stub_request(:get, %r{app.ticketmaster.com/discovery/v2/events\.json})
        .to_return(status: 200, body: events_body, headers: { "Content-Type" => "application/json" })

      stub_request(:get, %r{app.ticketmaster.eu/mfxapi/v2/events/449621\?})
        .to_return(status: 200, body: eu_details_body, headers: { "Content-Type" => "application/json" })

      result = TicketmasterService.new.fetch_and_create_events(artist)

      assert_equal 1, result[:created]

      tm_event = TicketmasterEvent.find_by(ticketmaster_event_id: "449621")
      concert = tm_event&.concert

      assert_not_nil concert
      assert_equal BigDecimal("20.81"), concert.price
      assert_equal "GBP", concert.price_currency
      assert_equal "onsale", tm_event.status_code
      assert_requested(:get, %r{app.ticketmaster.eu/mfxapi/v2/events/449621\?})
    end
  end
end
