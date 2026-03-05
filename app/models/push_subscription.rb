# frozen_string_literal: true

class PushSubscription < ApplicationRecord
  belongs_to :user

  validates :endpoint, :p256dh_key, :auth_key, presence: true
  validates :endpoint, uniqueness: true

  scope :active, -> { where(revoked_at: nil) }

  def mark_revoked!
    update!(revoked_at: Time.current)
  end
end
