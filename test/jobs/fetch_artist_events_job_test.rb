# frozen_string_literal: true

require "test_helper"

class FetchArtistEventsJobTest < ActiveJob::TestCase
  setup do
    @artist = create(:artist)
  end

  test "calls fetch_and_store_artist then fetch_and_create_events" do
    mock_service = mock("ticketmaster_service")
    mock_service.stubs(:fetch_and_store_artist).returns(
      { success: true, ticketmaster_id: "tm1", ticketmaster_name: "Artist" }
    )
    mock_service.expects(:fetch_and_create_events).returns(
      { created: 2, total: 2, errors: [] }
    )
    TicketmasterService.stubs(:new).returns(mock_service)

    FetchArtistEventsJob.perform_now(@artist.id)
  end

  test "does nothing when artist not found" do
    assert_nothing_raised do
      FetchArtistEventsJob.perform_now(99999999)
    end
  end
end
