class AddAudiodbFieldsToArtists < ActiveRecord::Migration[8.1]
  def change
    change_table :artists, bulk: true do |t|
      # TheAudioDB identification
      t.string :audiodb_id

      # Extended biography
      t.text :biography

      # Additional images
      t.string :fanart_url
      t.string :banner_url
      t.string :logo_url
      t.string :thumbnail_url

      # Additional metadata
      t.string :music_style
      t.integer :formed_year
      t.integer :disbanded_year

      # Social links
      t.string :facebook_url
      t.string :twitter_handle

      # Enrichment tracking
      t.datetime :audiodb_enriched_at
      t.string :audiodb_status
    end

    add_index :artists, :audiodb_id
    add_index :artists, :audiodb_status
  end
end
