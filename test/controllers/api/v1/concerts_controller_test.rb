# frozen_string_literal: true

require "test_helper"

class Api::V1::ConcertsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @artist  = create(:artist)
    @concert = create(:concert, :upcoming, artist: @artist)
    @admin   = create(:user, :admin)
    @user    = create(:user)
  end

  test "GET /api/v1/concerts returns list" do
    get "/api/v1/concerts", headers: json_headers
    assert_response :success
    json = JSON.parse(response.body)
    assert json.key?("concerts")
  end

  test "GET /api/v1/concerts/upcoming returns upcoming concerts" do
    past = create(:concert, :past, artist: @artist)
    get "/api/v1/concerts/upcoming", headers: json_headers
    assert_response :success
    json = JSON.parse(response.body)
    ids = json["concerts"].map { |c| c["id"] }
    assert_includes ids, @concert.id
    assert_not_includes ids, past.id
  end

  test "GET /api/v1/concerts/nearby returns nearby concerts" do
    get "/api/v1/concerts/nearby", params: { lat: 48.2773, lng: -3.5718, radius: 100 }, headers: json_headers
    assert_response :success
  end

  test "GET /api/v1/concerts/nearby returns 400 without lat/lng" do
    get "/api/v1/concerts/nearby", headers: json_headers
    assert_response :bad_request
  end

  test "GET /api/v1/concerts/:id returns concert" do
    get "/api/v1/concerts/#{@concert.id}", headers: json_headers
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal @concert.id, json["concert"]["id"]
  end

  test "POST /api/v1/concerts creates concert as admin" do
    assert_difference "Concert.count", 1 do
      post "/api/v1/concerts",
           params: {
             concert: {
               artist_id: @artist.id,
               title: "New Concert",
               venue_name: "Venue",
               city: "Carhaix",
               country: "France",
               starts_at: 2.weeks.from_now,
               latitude: 48.2773,
               longitude: -3.5718
             }
           },
           headers: auth_headers(@admin)
    end
    assert_response :created
  end

  test "DELETE /api/v1/concerts/:id as admin" do
    assert_difference "Concert.count", -1 do
      delete "/api/v1/concerts/#{@concert.id}", headers: auth_headers(@admin)
    end
    assert_response :ok
  end
end
