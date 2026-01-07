class CreateSuggestedArtists < ActiveRecord::Migration[8.1]
  def change
    create_table :suggested_artists do |t|
      t.references :user, null: false, foreign_key: true
      t.references :artist, null: false, foreign_key: true
      t.string :spotify_artist_id
      t.integer :rank
      t.datetime :synced_at

      t.timestamps
    end

    add_index :suggested_artists, [ :user_id, :artist_id ], unique: true
    add_index :suggested_artists, :synced_at
  end
end
