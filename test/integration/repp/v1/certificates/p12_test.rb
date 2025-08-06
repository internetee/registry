require 'test_helper'

class ReppV1CertificatesP12Test < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    @auth_headers = { 'Authorization' => "Basic #{token}" }

    adapter = ENV['shunter_default_adapter'].constantize.new
    adapter&.clear!
  end

  def test_enqueues_p12_generation_job_and_returns_success
    assert_enqueued_with(job: P12GeneratorJob, args: [@user.id.to_s]) do
      post p12_repp_v1_certificates_path, headers: @auth_headers,
                                          params: { p12: { api_user_id: @user.id } }
    end

    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'P12 certificate generation started. Please refresh the page in a few seconds.',
                 json[:message]
  end

  def test_returns_parameter_missing_when_p12_param_absent
    post p12_repp_v1_certificates_path, headers: @auth_headers, params: {}
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal 2003, json[:code]
  end

  def test_returns_error_response_if_throttled
    ENV['shunter_default_threshold'] = '1'
    ENV['shunter_enabled'] = 'true'

    post p12_repp_v1_certificates_path, headers: @auth_headers,
                                        params: { p12: { api_user_id: @user.id } }
    post p12_repp_v1_certificates_path, headers: @auth_headers,
                                        params: { p12: { api_user_id: @user.id } }

    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal 2502, json[:code]
    assert response.body.include?(Shunter.default_error_message)
  ensure
    ENV['shunter_default_threshold'] = '10000'
    ENV['shunter_enabled'] = 'false'
  end
end 
