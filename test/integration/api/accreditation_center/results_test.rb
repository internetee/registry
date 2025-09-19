require 'test_helper'

class ResultsTest < ApplicationIntegrationTest
  def setup
    super
    @registrar = registrars(:bestnames)
    @accredited_user = users(:api_bestnames)
    @accredited_user.update!(accreditation_date: 1.week.ago)

    @non_accredited_user = users(:api_bestnames_epp)
    @non_accredited_user.update!(accreditation_date: nil)

    @other_registrar_user = users(:api_goodnames)
    @other_registrar_user.update!(accreditation_date: 2.weeks.ago)
  end

  def parse_json
    JSON.parse(response.body, symbolize_names: true)
  end

  def assert_successful_response
    assert_response :success
    assert_includes response.content_type, "application/json"
    assert_equal 1000, parse_json[:code]
  end

  def assert_error_response(expected_message, status = :not_found)
    assert_response status
    assert_equal expected_message, parse_json[:errors]
  end

  def assert_valid_user(user_hash)
    %i[username identity_code accreditation_date].each do |key|
      assert user_hash.key?(key), "Expected #{key} in #{user_hash}"
    end
  end

  def test_show_returns_accredited_users
    get "/api/v1/accreditation_center/results", params: { registrar_name: @registrar.name }

    assert_successful_response
    usernames = parse_json[:registrar_users].map { |u| u[:username] }
    assert_includes usernames, @accredited_user.username
    assert_not_includes usernames, @other_registrar_user.username

    parse_json[:registrar_users].each { |u| assert_valid_user(u) }
  end

  def test_show_returns_empty_when_no_accredited
    @accredited_user.update!(accreditation_date: nil)
    get "/api/v1/accreditation_center/results", params: { registrar_name: @registrar.name }

    assert_successful_response
    assert_empty parse_json[:registrar_users]
  end

  def test_show_returns_error_when_registrar_missing
    get "/api/v1/accreditation_center/results", params: { registrar_name: "nonexistent" }
    assert_error_response("Registrar not found")
  end

  def test_show_returns_error_when_registrar_name_nil
    get "/api/v1/accreditation_center/results", params: { registrar_name: nil }
    assert_error_response("Registrar not found")
  end

  def test_show_api_user_returns_accredited_user
    get "/api/v1/accreditation_center/show_api_user",
        params: { username: @accredited_user.username, identity_code: @accredited_user.identity_code }

    assert_successful_response
    assert_valid_user(parse_json[:user_api])
  end

  def test_show_api_user_errors
    cases = [
      [{ username: "nonexistent", identity_code: "9999" }, "User not found"],
      [{ username: @non_accredited_user.username, identity_code: @non_accredited_user.identity_code }, "No accreditated yet"],
      [{ username: nil, identity_code: nil }, "User not found"]
    ]

    cases.each do |params, expected|
      get "/api/v1/accreditation_center/show_api_user", params: params
      assert_error_response(expected)
    end
  end

  def test_list_accreditated_returns_users
    get "/api/v1/accreditation_center/list_accreditated_api_users"

    assert_successful_response
    parse_json[:users].each { |u| assert_valid_user(u) }
  end

  def test_list_accreditated_errors_when_none
    User.update_all(accreditation_date: nil)
    get "/api/v1/accreditation_center/list_accreditated_api_users"

    assert_error_response("Accreditated users not found")
  end
end
