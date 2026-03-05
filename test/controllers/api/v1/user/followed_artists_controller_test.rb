# frozen_string_literal: true

require "test_helper"

class Api::V1::User::FollowedArtistsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user   = create(:user)
    @artist = create(:artist)
  end

  test "GET /api/v1/user/followed_artists returns followed artists" do
    @user.follow(@artist)
    get "/api/v1/user/followed_artists", headers: auth_headers(@user)
    assert_response :success
    json = JSON.parse(response.body)
    assert json.key?("artists")
    ids = json["artists"].map { |a| a["id"] }
    assert_includes ids, @artist.id
  end

  test "GET /api/v1/user/followed_artists requires auth" do
    get "/api/v1/user/followed_artists", headers: json_headers
    assert_response :unauthorized
  end

  test "POST /api/v1/user/followed_artists follows artist" do
    assert_difference "@user.followed_artists.count", 1 do
      post "/api/v1/user/followed_artists",
           params: { artist_id: @artist.id },
           headers: auth_headers(@user)
    end
    assert_response :created
  end

  test "DELETE /api/v1/user/followed_artists/:artist_id unfollows artist" do
    @user.follow(@artist)
    assert_difference "@user.followed_artists.count", -1 do
      delete "/api/v1/user/followed_artists/#{@artist.id}", headers: auth_headers(@user)
    end
    assert_response :ok
  end
end
