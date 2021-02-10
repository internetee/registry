require 'test_helper'

class ApiV1ContactRequestTest < ActionDispatch::IntegrationTest
  def setup
    @api_key = "Basic #{ENV['rwhois_internal_api_shared_key']}"
    @headers = { "Authorization": "#{@api_key}" }
    @json_create = { "contact_request": valid_contact_request_create }.as_json
    @json_update = { "contact_request": valid_contact_request_update }.as_json
    @contact_request = contact_requests(:new)
  end

  def test_authorizes_api_request
    post api_v1_contact_requests_path, params: @json_create, headers: @headers
    assert_response :created

    invalid_headers = { "Authorization": "Basic invalid_api_key" }
    post api_v1_contact_requests_path, params: @json_create, headers: invalid_headers
    assert_response :unauthorized
  end

  def test_saves_new_contact_request
    request_body = @json_create.dup
    random_mail = "#{rand(10000..99999)}@registry.test"
    request_body['contact_request']['email'] = random_mail

    post api_v1_contact_requests_path, params: request_body, headers: @headers
    assert_response :created

    contact_request = ContactRequest.last
    assert_equal contact_request.email, random_mail
    assert ContactRequest::STATUS_NEW, contact_request.status
  end

  def test_updates_existing_contact_request
    request_body = @json_update.dup

    put api_v1_contact_request_path(@contact_request.id), params: request_body, headers: @headers
    assert_response :ok

    @contact_request.reload
    assert ContactRequest::STATUS_CONFIRMED, @contact_request.status
  end

  def test_not_updates_if_status_error
    request_body = @json_update.dup
    request_body['contact_request']['status'] = 'some_error_status'

    put api_v1_contact_request_path(@contact_request.id), params: request_body, headers: @headers
    assert_response 400

    @contact_request.reload
    assert ContactRequest::STATUS_NEW, @contact_request.status
  end

  def valid_contact_request_create
    {
      "email": "aaa@bbb.com",
      "whois_record_id": "1",
      "name": "test"
    }.as_json
  end

  def valid_contact_request_update
    {
      "status": "#{ContactRequest::STATUS_CONFIRMED}",
    }.as_json
  end
end
