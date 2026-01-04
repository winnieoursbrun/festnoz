# frozen_string_literal: true

class CreateConcerts < ActiveRecord::Migration[8.1]
  def change
    create_table :concerts do |t|
      t.references :artist, null: false, foreign_key: true

      # Concert details
      t.string :title, null: false
      t.text :description
      t.datetime :starts_at, null: false
      t.datetime :ends_at

      # Location details
      t.string :venue_name, null: false
      t.string :venue_address
      t.string :city, null: false
      t.string :country, null: false
      t.decimal :latitude, precision: 10, scale: 6, null: false
      t.decimal :longitude, precision: 10, scale: 6, null: false

      # Additional info
      t.string :ticket_url
      t.decimal :price, precision: 10, scale: 2
      t.string :price_currency, default: 'EUR'

      t.timestamps
    end

    # Note: artist_id index already created by t.references
    add_index :concerts, :starts_at
    add_index :concerts, [:latitude, :longitude]
    add_index :concerts, :city
  end
end
