# frozen_string_literal: true

class CreateTicketmasterEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :ticketmaster_events do |t|
      t.references :concert, null: false, foreign_key: true, index: { unique: true }
      t.references :artist, null: false, foreign_key: true

      t.string :ticketmaster_event_id, null: false
      t.string :name
      t.string :event_url
      t.string :locale
      t.string :status_code

      t.decimal :price_min, precision: 10, scale: 2
      t.decimal :price_max, precision: 10, scale: 2
      t.string :price_currency
      t.string :price_type

      t.datetime :starts_at
      t.datetime :sales_start_at
      t.datetime :sales_end_at
      t.datetime :last_synced_at, null: false

      t.text :info
      t.text :please_note
      t.jsonb :payload, null: false, default: {}

      t.timestamps
    end

    add_index :ticketmaster_events, :ticketmaster_event_id, unique: true
    add_index :ticketmaster_events, :starts_at
    add_index :ticketmaster_events, [ :artist_id, :starts_at ]
  end
end
