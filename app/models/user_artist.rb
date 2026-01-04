# frozen_string_literal: true

class UserArtist < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :artist

  # Validations
  validates :user_id, uniqueness: { scope: :artist_id }
end
