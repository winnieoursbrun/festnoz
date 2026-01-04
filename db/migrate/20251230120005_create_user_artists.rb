# frozen_string_literal: true

class CreateUserArtists < ActiveRecord::Migration[8.1]
  def change
    create_table :user_artists do |t|
      t.references :user, null: false, foreign_key: true
      t.references :artist, null: false, foreign_key: true

      t.timestamps
    end

    add_index :user_artists, [:user_id, :artist_id], unique: true
  end
end
