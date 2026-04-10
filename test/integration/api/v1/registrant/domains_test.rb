require 'test_helper'
require 'auth_token/auth_token_creator'

class RegistrantApiV1DomainsTest < ActionDispatch::IntegrationTest
  setup do
    Rails.cache.clear
    @user = users(:registrant)
    @registrar = registrars(:bestnames)
    @contact = contacts(:john)
  end

  def test_get_default_counts_of_domains
    get api_v1_registrant_domains_path + "?tech=init", as: :json,
        headers: { 'HTTP_AUTHORIZATION' => auth_token }

    assert_response :ok

    response_json = JSON.parse(response.body)
    assert_equal 4, response_json['total']
    assert_equal 4, response_json['count']
  end

  def test_get_default_counts_of_direct_domains
    stub = build_company_register_stub(raise_error: CompanyRegister::NotAvailableError)

    CompanyRegister::Client.stub(:new, stub) do
      get api_v1_registrant_domains_path + "?tech=init", as: :json,
          headers: { 'HTTP_AUTHORIZATION' => auth_token }
    end

    assert_response :ok
    response_json = JSON.parse(response.body)
    assert_equal 4, response_json['total']
    assert_equal 4, response_json['count']
  end

  def test_outage_with_stale_cache_returns_company_linked_domains
    stale_key = "registrant/listing_company_codes_stale/v1/#{@user.id}"
    Rails.cache.write(stale_key, %w[1234567], expires_in: 1.hour)

    stub = build_company_register_stub(raise_error: CompanyRegister::NotAvailableError)

    CompanyRegister::Client.stub(:new, stub) do
      get api_v1_registrant_domains_path + "?tech=init", as: :json,
          headers: { 'HTTP_AUTHORIZATION' => auth_token }
    end

    assert_response :ok
    response_json = JSON.parse(response.body)
    domain_names = response_json['domains'].map { |d| d['name'] }
    assert_includes domain_names, 'shop.test'
  end

  def test_outage_no_cache_returns_direct_domains_only
    stub = build_company_register_stub(raise_error: CompanyRegister::NotAvailableError)

    CompanyRegister::Client.stub(:new, stub) do
      get api_v1_registrant_domains_path + "?tech=init", as: :json,
          headers: { 'HTTP_AUTHORIZATION' => auth_token }
    end

    assert_response :ok
    response_json = JSON.parse(response.body)
    assert_equal 4, response_json['total']
    domain_names = response_json['domains'].map { |d| d['name'] }
    assert_includes domain_names, 'shop.test'
  end

  def test_soap_fault_returns_direct_domains
    stub = build_company_register_stub(raise_error: CompanyRegister::SOAPFaultError)

    CompanyRegister::Client.stub(:new, stub) do
      get api_v1_registrant_domains_path + "?tech=init", as: :json,
          headers: { 'HTTP_AUTHORIZATION' => auth_token }
    end

    assert_response :ok
    response_json = JSON.parse(response.body)
    assert_equal 4, response_json['total']
    domain_names = response_json['domains'].map { |d| d['name'] }
    assert_includes domain_names, 'shop.test'
  end

  def test_totals_match_in_degrade_mode
    stub = build_company_register_stub(raise_error: CompanyRegister::NotAvailableError)

    CompanyRegister::Client.stub(:new, stub) do
      get api_v1_registrant_domains_path + "?tech=init", as: :json,
          headers: { 'HTTP_AUTHORIZATION' => auth_token }
    end

    assert_response :ok
    response_json = JSON.parse(response.body)
    assert_equal response_json['count'], response_json['total']
  end

  def test_resolver_called_once_per_request
    call_count = 0
    counting_factory = lambda do |user|
      call_count += 1
      resolver = Object.new
      resolver.define_singleton_method(:call) { [] }
      resolver
    end

    ListingCompanyCodesResolver.stub(:new, counting_factory) do
      get api_v1_registrant_domains_path + "?tech=init", as: :json,
          headers: { 'HTTP_AUTHORIZATION' => auth_token }
    end

    assert_equal 1, call_count
  end

  def test_json_shape_preserved
    get api_v1_registrant_domains_path + "?tech=init", as: :json,
        headers: { 'HTTP_AUTHORIZATION' => auth_token }

    assert_response :ok
    response_json = JSON.parse(response.body)
    assert response_json.key?('total')
    assert response_json.key?('count')
    assert response_json.key?('domains')
    assert_kind_of Array, response_json['domains']
  end

  private

  def auth_token
    token_creator = AuthTokenCreator.create_with_defaults(@user)
    hash = token_creator.token_in_hash
    "Bearer #{hash[:access_token]}"
  end

  def build_company_register_stub(raise_error:)
    stub = Object.new
    stub.define_singleton_method(:representation_rights) do |citizen_personal_code:, citizen_country_code:|
      raise raise_error
    end
    stub
  end
end
