require 'test_helper'

class ApiV1InternalRdapRegistrarsTest < ApplicationIntegrationTest
  def setup
    @registrar = registrars(:bestnames)
    # In production, registrar codes are stored upper-cased by Registrar#code=
    # (the controller upcases the lookup to match, per the contract). The shared
    # fixture is loaded via raw INSERT, bypassing the setter, so normalize here.
    @registrar.update_columns(code: @registrar.code.upcase)
    ENV['rdap_internal_api_shared_key'] = 'test-rdap-key'
    ENV['rdap_internal_api_allowed_ips'] = '127.0.0.1,::1'
    @header = { 'Authorization' => 'Basic test-rdap-key' }
  end

  def teardown
    ENV.delete('rdap_internal_api_shared_key')
    ENV.delete('rdap_internal_api_allowed_ips')
    super
  end

  def test_returns_registrar_narrow_shape
    get '/api/v1/internal/rdap/registrars/bestnames', headers: @header
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    # Full-hash equality: proves the response is EXACTLY the narrow 4-key shape
    # (no email/reg_no leak) and avoids the assert_nil deprecation when a fixture
    # field is nil.
    assert_equal(
      { code: 'BESTNAMES', name: @registrar.name, phone: @registrar.phone, website: @registrar.website },
      json
    )
  end

  def test_does_not_expose_email_or_reg_no
    get '/api/v1/internal/rdap/registrars/bestnames', headers: @header
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    refute json.key?(:email), 'email MUST NOT appear on the entity endpoint'
    refute json.key?(:reg_no), 'reg_no MUST NOT appear on the entity endpoint'
    refute_includes response.body, @registrar.email
  end

  def test_upcases_code_before_lookup
    get '/api/v1/internal/rdap/registrars/BESTNAMES', headers: @header
    assert_response :ok
  end

  def test_returns_404_when_not_found
    get '/api/v1/internal/rdap/registrars/nope', headers: @header
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :not_found
    assert_equal 'Registrar not found', json[:message]
  end

  def test_requires_authentication
    get '/api/v1/internal/rdap/registrars/bestnames'
    assert_response :unauthorized
  end
end
