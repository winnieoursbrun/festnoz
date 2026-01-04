# frozen_string_literal: true

class CreateArtists < ActiveRecord::Migration[8.1]
  def change
    create_table :artists do |t|
      t.string :name, null: false
      t.text :description
      t.string :genre
      t.string :image_url
      t.string :country
      t.string :website

      t.timestamps
    end

    add_index :artists, :name
    add_index :artists, :genre
  end
end
