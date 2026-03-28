# frozen_string_literal: true

class TicketmasterEvent < ApplicationRecord
  belongs_to :concert
  belongs_to :artist

  validates :ticketmaster_event_id, presence: true, uniqueness: true
  validates :concert_id, uniqueness: true
end
