class AddUnaccentExtensionAndSearchIndexes < ActiveRecord::Migration[8.1]
  def up
    # Enable extensions
    enable_extension 'unaccent'
    enable_extension 'pg_trgm'

    # Create an immutable wrapper function for unaccent using SQL language
    execute "CREATE OR REPLACE FUNCTION immutable_unaccent(input_text text) RETURNS text AS 'SELECT public.unaccent(input_text);' LANGUAGE SQL IMMUTABLE;"

    # Functional indexes for accent-insensitive search
    execute "CREATE INDEX index_artists_on_name_unaccent ON artists (immutable_unaccent(name))"
    execute "CREATE INDEX index_concerts_on_title_unaccent ON concerts (immutable_unaccent(title))"
    execute "CREATE INDEX index_concerts_on_venue_name_unaccent ON concerts (immutable_unaccent(venue_name))"
    execute "CREATE INDEX index_concerts_on_city_unaccent ON concerts (immutable_unaccent(city))"

    # GIN tsvector indexes for full-text search (using 'simple' config for proper nouns / multilingual content)
    execute "CREATE INDEX index_artists_on_tsvector ON artists USING gin(to_tsvector('simple', lower(immutable_unaccent(name))))"
    execute "CREATE INDEX index_concerts_on_title_tsvector ON concerts USING gin(to_tsvector('simple', lower(immutable_unaccent(title))))"
    execute "CREATE INDEX index_concerts_on_venue_tsvector ON concerts USING gin(to_tsvector('simple', lower(immutable_unaccent(venue_name))))"
    execute "CREATE INDEX index_concerts_on_city_tsvector ON concerts USING gin(to_tsvector('simple', lower(immutable_unaccent(city))))"
  end

  def down
    # Remove GIN tsvector indexes
    execute "DROP INDEX IF EXISTS index_concerts_on_city_tsvector"
    execute "DROP INDEX IF EXISTS index_concerts_on_venue_tsvector"
    execute "DROP INDEX IF EXISTS index_concerts_on_title_tsvector"
    execute "DROP INDEX IF EXISTS index_artists_on_tsvector"

    # Remove functional indexes
    execute "DROP INDEX IF EXISTS index_concerts_on_city_unaccent"
    execute "DROP INDEX IF EXISTS index_concerts_on_venue_name_unaccent"
    execute "DROP INDEX IF EXISTS index_concerts_on_title_unaccent"
    execute "DROP INDEX IF EXISTS index_artists_on_name_unaccent"

    # Remove our immutable wrapper function
    execute "DROP FUNCTION IF EXISTS immutable_unaccent(text)"

    # Disable extensions
    disable_extension 'pg_trgm'
    disable_extension 'unaccent'
  end
end
