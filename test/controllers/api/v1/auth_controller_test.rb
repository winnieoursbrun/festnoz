# frozen_string_literal: true

require "test_helper"

class Api::V1::AuthControllerTest < ActionDispatch::IntegrationTest
  test "GET /api/v1/auth/me returns current user" do
    user = create(:user)
    get "/api/v1/auth/me", headers: auth_headers(user)
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal user.id, json["user"]["id"]
    assert_equal user.email, json["user"]["email"]
  end

  test "GET /api/v1/auth/me returns 401 without token" do
    get "/api/v1/auth/me", headers: json_headers
    assert_response :unauthorized
  end
end
