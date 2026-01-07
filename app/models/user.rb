# frozen_string_literal: true

class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Denylist

  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :omniauthable,
         :jwt_authenticatable, jwt_revocation_strategy: self,
         omniauth_providers: [:spotify]

  # Associations
  has_many :user_artists, dependent: :destroy
  has_many :followed_artists, through: :user_artists, source: :artist
  has_many :suggested_artists, dependent: :destroy
  has_many :suggested_artist_records, through: :suggested_artists, source: :artist

  # Validations
  validates :username, presence: true, uniqueness: true,
            length: { minimum: 3, maximum: 30 }
  validates :email, presence: true, uniqueness: true, if: -> { provider.blank? }
  validates :password, presence: true, if: -> { provider.blank? && !password.nil? }

  # Class methods
  def self.from_omniauth(auth)
    user = where(provider: auth.provider, uid: auth.uid).first_or_initialize do |u|
      u.email = auth.info.email || "#{auth.uid}@spotify.temp"
      u.password = Devise.friendly_token[0, 20]
      u.username = auth.info.display_name || auth.info.nickname || "spotify_user_#{auth.uid}"
    end

    # Always update Spotify tokens (even for existing users)
    user.spotify_access_token = auth.credentials.token
    user.spotify_refresh_token = auth.credentials.refresh_token
    user.spotify_token_expires_at = Time.at(auth.credentials.expires_at) if auth.credentials.expires_at
    user.save!

    user
  end

  # Instance methods
  def following?(artist)
    followed_artists.include?(artist)
  end

  def follow(artist)
    followed_artists << artist unless following?(artist)
  end

  def unfollow(artist)
    followed_artists.delete(artist)
  end

  def spotify_authenticated?
    provider == "spotify" && spotify_access_token.present?
  end

  def update_spotify_tokens(access_token, refresh_token, expires_at)
    update(
      spotify_access_token: access_token,
      spotify_refresh_token: refresh_token,
      spotify_token_expires_at: Time.at(expires_at)
    )
  end
end
