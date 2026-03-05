class SuggestedArtist < ApplicationRecord
  belongs_to :user
  belongs_to :artist

  validates :user_id, uniqueness: { scope: :artist_id }
  validates :rank, numericality: { greater_than_or_equal_to: 0, allow_nil: true }

  scope :ordered, -> { order(rank: :asc) }
  scope :recent, -> { order(synced_at: :desc) }
  scope :not_followed, -> {
    where("suggested_artists.artist_id NOT IN (SELECT user_artists.artist_id FROM user_artists WHERE user_artists.user_id = suggested_artists.user_id)")
  }
end
