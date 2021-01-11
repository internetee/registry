require 'test_helper'

class ApiV1ContactRequestTest < ActionDispatch::IntegrationTest
  def setup
    @api_key = "Basic #{ENV['api_shared_key']}"
    @headers = { "Authorization": "#{@api_key}" }
    @json_body = { "contact_request": valid_contact_request_body }.as_json
  end

  def test_authorizes_api_request
    post api_v1_contact_requests_path, params: @json_body, headers: @headers
    assert_response :created

    invalid_headers = { "Authorization": "Basic invalid_api_key" }
    post api_v1_contact_requests_path, params: @json_body, headers: invalid_headers
    assert_response :unauthorized
  end

  def test_saves_new_contact_request
    request_body = @json_body.dup
    random_mail = "#{rand(10000..99999)}@registry.test"
    request_body['contact_request']['email'] = random_mail

    post api_v1_contact_requests_path, params: request_body, headers: @headers
    assert_response :created

    contact_request = ContactRequest.last
    assert_equal contact_request.email, random_mail
    assert ContactRequest::STATUS_NEW, contact_request.status
  end

  def valid_contact_request_body
    {
      "email": "aaa@bbb.com",
      "whois_record_id": "1",
      "name": "test"
    }.as_json
  end
end
