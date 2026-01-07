class AddSpotifyFieldsToArtists < ActiveRecord::Migration[8.1]
  def change
    add_column :artists, :spotify_id, :string
    add_index :artists, :spotify_id, unique: true
    add_column :artists, :spotify_url, :string
    add_column :artists, :popularity, :integer
  end
end
