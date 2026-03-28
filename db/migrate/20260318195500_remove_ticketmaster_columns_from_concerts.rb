# frozen_string_literal: true

class RemoveTicketmasterColumnsFromConcerts < ActiveRecord::Migration[8.1]
  def change
    remove_column :concerts, :ticketmaster_id, :string
    remove_column :concerts, :ticketmaster_url, :string
  end
end
