# frozen_string_literal: true

require "test_helper"

class ArtistEnrichmentJobTest < ActiveJob::TestCase
  setup do
    @artist = create(:artist)
  end

  test "calls AudiodbService to enrich artist" do
    mock_service = mock("audiodb_service")
    mock_service.expects(:enrich_artist).with(@artist).returns(true)
    AudiodbService.stubs(:new).returns(mock_service)

    ArtistEnrichmentJob.perform_now(@artist.id)
  end

  test "skips recently enriched artist" do
    @artist.update_columns(audiodb_status: "enriched", audiodb_enriched_at: 1.day.ago)
    AudiodbService.expects(:new).never

    assert_nothing_raised do
      ArtistEnrichmentJob.perform_now(@artist.id)
    end
  end

  test "does nothing when artist not found" do
    assert_nothing_raised do
      ArtistEnrichmentJob.perform_now(99999999)
    end
  end
end
