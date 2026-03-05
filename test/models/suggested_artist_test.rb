# frozen_string_literal: true

require "test_helper"

class SuggestedArtistTest < ActiveSupport::TestCase
  subject { create(:suggested_artist) }

  should belong_to(:user)
  should belong_to(:artist)
  should validate_uniqueness_of(:user_id).scoped_to(:artist_id)

  describe "scopes" do
    it "orders by rank ascending" do
      user = create(:user)
      artist1 = create(:artist)
      artist2 = create(:artist)
      s1 = create(:suggested_artist, user: user, artist: artist1, rank: 2)
      s2 = create(:suggested_artist, user: user, artist: artist2, rank: 1)
      assert_equal s2, SuggestedArtist.ordered.first
    end

    it "not_followed excludes already-followed artists" do
      user = create(:user)
      followed_artist = create(:artist)
      other_artist = create(:artist)
      user.follow(followed_artist)
      s1 = create(:suggested_artist, user: user, artist: followed_artist, rank: 1)
      s2 = create(:suggested_artist, user: user, artist: other_artist, rank: 2)
      unfollowed = user.suggested_artists.not_followed
      assert_not_includes unfollowed, s1
      assert_includes unfollowed, s2
    end
  end
end
