class AddOmniauthToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_column :users, :spotify_access_token, :text
    add_column :users, :spotify_refresh_token, :text
    add_column :users, :spotify_token_expires_at, :datetime

    add_index :users, [:provider, :uid], unique: true
  end
end
