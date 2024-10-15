# frozen_string_literal: true

require 'test_helper'

class IdentificationServiceTest < ActiveSupport::TestCase
  def setup
    @service = Eeid::IdentificationService.new
  end

  def test_create_identification_request_success
    request_params = {
      claims_required: [{
        type: 'sub',
        value: 'EE1234567'
      }],
      reference: '111:111'
    }
    response_body = { id: '123', status: 'created' }.to_json

    stub_request(:post, %r{api/auth/v1/token})
      .to_return(status: 200, body: { access_token: 'mock_token' }.to_json)

    stub_request(:post, %r{api/ident/v1/identification_requests})
      .with(
        headers: { 'Authorization' => 'Bearer mock_token' },
        body: request_params.to_json
      )
      .to_return(status: 201, body: response_body, headers: { 'Content-Type' => 'application/json' })

    result = @service.create_identification_request(request_params)
    assert_equal JSON.parse(response_body), result
    assert_equal 'mock_token', @service.instance_variable_get(:@token)
  end

  def test_create_identification_request_failure
    request_params = {
      claims_required: [{
        type: 'sub',
        value: 'EE1234567'
      }],
      reference: '111:111'
    }

    stub_request(:post, %r{api/auth/v1/token})
      .to_return(status: 200, body: { access_token: 'mock_token' }.to_json)

    stub_request(:post, %r{api/ident/v1/identification_requests})
      .with(
        headers: { 'Authorization' => 'Bearer mock_token' },
        body: request_params.to_json
      )
      .to_return(status: 400, body: { error: 'Bad Request' }.to_json, headers: { 'Content-Type' => 'application/json' })

    assert_raises(Eeid::IdentError, 'Bad Request') do
      @service.create_identification_request(request_params)
    end
  end

  def test_get_identification_request_success
    id = '123'
    response_body = { id: id, status: 'completed' }.to_json

    stub_request(:post, %r{api/auth/v1/token})
      .to_return(status: 200, body: { access_token: 'mock_token' }.to_json)

    stub_request(:get, %r{api/ident/v1/identification_requests/#{id}})
      .with(headers: { 'Authorization' => 'Bearer mock_token' })
      .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })

    result = @service.get_identification_request(id)
    assert_equal JSON.parse(response_body), result
    assert_equal 'mock_token', @service.instance_variable_get(:@token)
  end

  def test_get_identification_request_failure
    id = '123'

    stub_request(:post, %r{api/auth/v1/token})
      .to_return(status: 200, body: { access_token: 'mock_token' }.to_json)

    stub_request(:get, %r{api/ident/v1/identification_requests/#{id}})
      .with(headers: { 'Authorization' => 'Bearer mock_token' })
      .to_return(status: 404, body: { error: 'Not Found' }.to_json)

    assert_raises(Eeid::IdentError, 'Not Found') do
      @service.get_identification_request(id)
    end
  end

  def test_authentication_needed_for_requests
    stub_request(:post, %r{api/auth/v1/token})
      .to_return(status: 401, body: { error: 'Invalid credentials' }.to_json)

    assert_raises(Eeid::IdentError) do
      @service.create_identification_request({ key: 'value' })
    end

    assert_raises(Eeid::IdentError) do
      @service.get_identification_request('123')
    end

    assert_equal nil, @service.instance_variable_get(:@token)
  end
end
