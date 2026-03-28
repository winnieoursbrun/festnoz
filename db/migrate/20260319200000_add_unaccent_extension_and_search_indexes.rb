class AddUnaccentExtensionAndSearchIndexes < ActiveRecord::Migration[8.1]
  def up
    # Enable unaccent extension
    enable_extension 'unaccent'

    # Create an immutable wrapper function for unaccent using SQL language
    execute "CREATE OR REPLACE FUNCTION immutable_unaccent(input_text text) RETURNS text AS 'SELECT public.unaccent(input_text);' LANGUAGE SQL IMMUTABLE;"

    # Add functional indexes for accent-insensitive search using our immutable wrapper

    # Artist name search (main priority)
    execute "CREATE INDEX index_artists_on_name_unaccent ON artists (immutable_unaccent(name))"

    # Concert searchable fields
    execute "CREATE INDEX index_concerts_on_title_unaccent ON concerts (immutable_unaccent(title))"
    execute "CREATE INDEX index_concerts_on_venue_name_unaccent ON concerts (immutable_unaccent(venue_name))"
    execute "CREATE INDEX index_concerts_on_city_unaccent ON concerts (immutable_unaccent(city))"

    # Keep existing indexes for exact matching and foreign keys
  end

  def down
    # Remove indexes
    execute "DROP INDEX IF EXISTS index_concerts_on_city_unaccent"
    execute "DROP INDEX IF EXISTS index_concerts_on_venue_name_unaccent"
    execute "DROP INDEX IF EXISTS index_concerts_on_title_unaccent"
    execute "DROP INDEX IF EXISTS index_artists_on_name_unaccent"

    # Remove our immutable wrapper function
    execute "DROP FUNCTION IF EXISTS immutable_unaccent(text)"

    # Disable extension
    disable_extension 'unaccent'
  end
end
