# frozen_string_literal: true

class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Denylist

  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  # Associations
  has_many :user_artists, dependent: :destroy
  has_many :followed_artists, through: :user_artists, source: :artist

  # Validations
  validates :username, presence: true, uniqueness: true,
            length: { minimum: 3, maximum: 30 }
  validates :email, presence: true, uniqueness: true

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
end
