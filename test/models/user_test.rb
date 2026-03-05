# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  subject { create(:user) }

  # Associations
  should have_many(:user_artists).dependent(:destroy)
  should have_many(:followed_artists).through(:user_artists)
  should have_many(:suggested_artists).dependent(:destroy)

  # Validations
  should validate_presence_of(:username)
  should validate_uniqueness_of(:username)
  should validate_length_of(:username).is_at_least(3).is_at_most(30)

  describe "#follow and #unfollow" do
    it "follows an artist" do
      user = create(:user)
      artist = create(:artist)
      user.follow(artist)
      assert user.following?(artist)
    end

    it "does not double-follow" do
      user = create(:user)
      artist = create(:artist)
      user.follow(artist)
      user.follow(artist)
      assert_equal 1, user.followed_artists.count
    end

    it "unfollows an artist" do
      user = create(:user)
      artist = create(:artist)
      user.follow(artist)
      user.unfollow(artist)
      assert_not user.following?(artist)
    end
  end

  describe "#spotify_authenticated?" do
    it "returns true for spotify-connected user" do
      user = create(:user, :spotify_connected)
      assert user.spotify_authenticated?
    end

    it "returns false for regular user" do
      user = create(:user)
      assert_not user.spotify_authenticated?
    end
  end

  describe "#generate_account_deletion_token!" do
    it "sets token digest and requested_at" do
      user = create(:user)
      token = user.generate_account_deletion_token!
      assert user.account_deletion_token_digest.present?
      assert user.account_deletion_requested_at.present?
      assert user.account_deletion_token_valid?(token)
    end

    it "returns false for wrong token" do
      user = create(:user)
      user.generate_account_deletion_token!
      assert_not user.account_deletion_token_valid?("wrong-token")
    end

    it "returns false for expired token" do
      user = create(:user)
      token = user.generate_account_deletion_token!
      user.update_column(:account_deletion_requested_at, 25.hours.ago)
      assert_not user.account_deletion_token_valid?(token)
    end
  end

  describe "jti callback" do
    it "sets jti before create" do
      user = build(:user, jti: nil)
      user.save!
      assert user.jti.present?
    end
  end
end
