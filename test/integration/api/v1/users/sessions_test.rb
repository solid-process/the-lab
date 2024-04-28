# frozen_string_literal: true

require "test_helper"

class API::V1::User::SessionsTest < ActionDispatch::IntegrationTest
  test "#create responds with 400 when params are missing" do
    params = [{}, {user: {}}, {user: nil}].sample

    post(api_v1_user_sessions_url, params:)

    assert_api_v1_response_with_error(:bad_request)
  end

  test "#create responds with 401 when email is invalid" do
    email = ["@", "invalid", "invalid@", ""].sample

    params = {
      user: {
        email: email,
        password: "123123123",
        password_confirmation: "123123123"
      }
    }

    post(api_v1_user_sessions_url, params:)

    assert_api_v1_response_with_error(:unauthorized)
  end

  test "#create responds with 422 when password is invalid" do
    password = ["", "123", "1234567"].sample

    params = {user: {email: "email@example.com", password:}}

    post(api_v1_user_sessions_url, params:)

    assert_api_v1_response_with_error(:unauthorized)
  end

  test "#create responds with 200 when params are valid" do
    params = {user: {email: "one@email.com", password: "123123123"}}

    post(api_v1_user_sessions_url, params:)

    json_data = assert_api_v1_response_with_success(:ok)

    assert_equal(
      User.find_by(email: params[:user][:email]).token.access_token,
      json_data["access_token"]
    )
  end
end
