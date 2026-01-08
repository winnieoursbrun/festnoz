class FetchArtistEventsJob < ApplicationJob
  queue_as :default

  def perform(artist_id)
    artist = Artist.find_by(id: artist_id)
    return unless artist

    Rails.logger.info("Fetching Ticketmaster data for artist: #{artist.name}")

    ticketmaster_service = TicketmasterService.new

    # First, fetch and store the artist entity if not already present
    unless artist.has_ticketmaster_entity?
      Rails.logger.info("Fetching Ticketmaster artist entity for: #{artist.name}")
      entity_result = ticketmaster_service.fetch_and_store_artist(artist)

      if entity_result[:success]
        Rails.logger.info(
          "Successfully linked artist to Ticketmaster: " \
          "#{entity_result[:ticketmaster_name]} (ID: #{entity_result[:ticketmaster_id]})"
        )
        # Reload to get updated ticketmaster_id
        artist.reload
      else
        Rails.logger.warn("Could not find artist entity in Ticketmaster: #{entity_result[:error]}")
        # Continue anyway - will fall back to keyword search for events
      end
    end

    # Now fetch events (will use artist ID if available)
    result = ticketmaster_service.fetch_and_create_events(artist)

    Rails.logger.info(
      "Completed fetching events for #{artist.name}: " \
      "Created #{result[:created]} out of #{result[:total]} events"
    )

    if result[:errors].any?
      Rails.logger.warn("Errors occurred: #{result[:errors].count} events failed")
    end

    result
  rescue StandardError => e
    Rails.logger.error("FetchArtistEventsJob failed for artist #{artist_id}: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    raise
  end
end
