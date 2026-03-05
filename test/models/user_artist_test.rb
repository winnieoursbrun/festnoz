# frozen_string_literal: true

require "test_helper"

class UserArtistTest < ActiveSupport::TestCase
  subject { create(:user_artist) }

  should belong_to(:user)
  should belong_to(:artist)
  should validate_uniqueness_of(:user_id).scoped_to(:artist_id)
end
