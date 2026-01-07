class SuggestedArtist < ApplicationRecord
  belongs_to :user
  belongs_to :artist

  validates :user_id, uniqueness: { scope: :artist_id }
  validates :rank, numericality: { greater_than_or_equal_to: 0, allow_nil: true }

  scope :ordered, -> { order(rank: :asc) }
  scope :recent, -> { order(synced_at: :desc) }
  scope :not_followed, -> {
    where.not(artist_id: UserArtist.select(:artist_id).where(user_id: arel_table[:user_id]))
  }
end
