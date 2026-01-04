# frozen_string_literal: true

class ArtistEnrichmentJob < ApplicationJob
  queue_as :default

  # Retry on rate limit errors with exponential backoff
  retry_on AudiodbService::RateLimitError, wait: :polynomially_longer, attempts: 5

  # Don't retry on other errors - mark as failed and move on
  discard_on AudiodbService::Error

  def perform(artist_id)
    artist = Artist.find_by(id: artist_id)
    return unless artist
    return if recently_enriched?(artist)

    service = AudiodbService.new
    service.enrich_artist(artist)
  end

  private

  def recently_enriched?(artist)
    # Skip if enriched in the last 7 days
    artist.audiodb_enriched_at.present? &&
      artist.audiodb_enriched_at > 7.days.ago
  end
end
