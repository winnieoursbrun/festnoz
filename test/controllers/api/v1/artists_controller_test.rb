# frozen_string_literal: true

require "test_helper"

class Api::V1::ArtistsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @artist = create(:artist)
    @user   = create(:user)
    @admin  = create(:user, :admin)
  end

  # --- Public endpoints ---

  test "GET /api/v1/artists returns list" do
    get "/api/v1/artists", headers: json_headers
    assert_response :success
    json = JSON.parse(response.body)
    assert json.key?("artists")
  end

  test "GET /api/v1/artists filters by genre" do
    create(:artist, genre: "Rock")
    get "/api/v1/artists", params: { genre: @artist.genre }, headers: json_headers
    assert_response :success
    json = JSON.parse(response.body)
    json["artists"].each { |a| assert_equal @artist.genre, a["genre"] }
  end

  test "GET /api/v1/artists/:id returns artist" do
    get "/api/v1/artists/#{@artist.id}", headers: json_headers
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal @artist.id, json["artist"]["id"]
  end

  test "GET /api/v1/artists/:id returns 404 for unknown artist" do
    get "/api/v1/artists/99999999", headers: json_headers
    assert_response :not_found
  end

  # --- Auth-protected admin endpoints ---

  test "POST /api/v1/artists requires admin" do
    post "/api/v1/artists",
         params: { artist: { name: "New Band", genre: "Fest-Noz" } },
         headers: auth_headers(@user)
    assert_response :forbidden
  end

  test "POST /api/v1/artists creates artist as admin" do
    assert_difference "Artist.count", 1 do
      post "/api/v1/artists",
           params: { artist: { name: "New Breizh Band", genre: "Fest-Noz" } },
           headers: auth_headers(@admin)
    end
    assert_response :created
  end

  test "POST /api/v1/artists returns 401 without auth" do
    post "/api/v1/artists", params: { artist: { name: "New", genre: "Fest-Noz" } }, headers: json_headers
    assert_response :unauthorized
  end

  test "PUT /api/v1/artists/:id updates artist as admin" do
    put "/api/v1/artists/#{@artist.id}",
        params: { artist: { genre: "Celtic Rock" } },
        headers: auth_headers(@admin)
    assert_response :success
    assert_equal "Celtic Rock", @artist.reload.genre
  end

  test "DELETE /api/v1/artists/:id destroys artist as admin" do
    assert_difference "Artist.count", -1 do
      delete "/api/v1/artists/#{@artist.id}", headers: auth_headers(@admin)
    end
    assert_response :ok
  end

  test "DELETE /api/v1/artists/:id returns 403 for non-admin" do
    delete "/api/v1/artists/#{@artist.id}", headers: auth_headers(@user)
    assert_response :forbidden
  end
end
