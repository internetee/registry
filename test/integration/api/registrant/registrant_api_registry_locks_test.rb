require 'test_helper'
require 'auth_token/auth_token_creator'

class RegistrantApiRegistryLocksTest < ApplicationIntegrationTest
  def setup
    super

    @original_registry_time = Setting.days_to_keep_business_registry_cache
    Setting.days_to_keep_business_registry_cache = 1
    travel_to Time.zone.parse('2010-07-05')

    @user = users(:registrant)
    @domain = domains(:airport)
    @auth_headers = { 'HTTP_AUTHORIZATION' => auth_token }
  end

  def teardown
    super

    Setting.days_to_keep_business_registry_cache = @original_registry_time
    travel_back
  end

  def test_can_lock_a_not_locked_domain
    post '/api/v1/registrant/domains/2df2c1a1-8f6a-490a-81be-8bdf29866880/registry_lock',
         {}, @auth_headers

    response_json = JSON.parse(response.body, symbolize_names: true)

    assert(response_json[:statuses].include?(DomainStatus::SERVER_DELETE_PROHIBITED))
    assert(response_json[:statuses].include?(DomainStatus::SERVER_TRANSFER_PROHIBITED))
    assert(response_json[:statuses].include?(DomainStatus::SERVER_UPDATE_PROHIBITED))

    @domain.reload
    assert(@domain.locked_by_registrant?)
  end

  def test_locking_a_domain_creates_a_version_record
    assert_difference '@domain.versions.count', 1 do
      post '/api/v1/registrant/domains/2df2c1a1-8f6a-490a-81be-8bdf29866880/registry_lock',
           {}, @auth_headers
    end

    @domain.reload
    assert_equal(@domain.updator, @user)
  end

  def test_cannot_lock_a_domain_in_pending_state
    @domain.statuses << DomainStatus::PENDING_UPDATE
    @domain.save

    post '/api/v1/registrant/domains/2df2c1a1-8f6a-490a-81be-8bdf29866880/registry_lock',
         {}, @auth_headers

    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal(422, response.status)
    assert_equal({ errors: [{ base: ['Domain cannot be locked'] }] }, response_json)
  end

  def test_cannot_lock_an_already_locked_domain
    @domain.apply_registry_lock
    assert(@domain.locked_by_registrant?)

    post '/api/v1/registrant/domains/2df2c1a1-8f6a-490a-81be-8bdf29866880/registry_lock',
         {}, @auth_headers

    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal(422, response.status)
    assert_equal({ errors: [{ base: ['Domain cannot be locked'] }] }, response_json)
  end

  def test_can_unlock_a_locked_domain
    @domain.apply_registry_lock

    delete '/api/v1/registrant/domains/2df2c1a1-8f6a-490a-81be-8bdf29866880/registry_lock',
         {}, @auth_headers

    response_json = JSON.parse(response.body, symbolize_names: true)
    assert(response_json[:statuses].include?(DomainStatus::OK))
    @domain.reload
    refute(@domain.locked_by_registrant?)
  end

  def test_cannot_unlock_a_not_locked_domain
    delete '/api/v1/registrant/domains/2df2c1a1-8f6a-490a-81be-8bdf29866880/registry_lock',
         {}, @auth_headers

    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal(422, response.status)
    assert_equal({ errors: [{ base: ['Domain is not locked'] }] }, response_json)
  end

  def test_returns_404_when_domain_is_not_found
    post '/api/v1/registrant/domains/random-uuid/registry_lock',
         {}, @auth_headers

    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal(404, response.status)
    assert_equal({ errors: [{ base: ['Domain not found'] }] }, response_json)
  end

  def test_technical_contact_cannot_lock_a_domain
    post '/api/v1/registrant/domains/647bcc48-8d5e-4a04-8ce5-2a3cd17b6eab/registry_lock',
         {}, @auth_headers

    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal(401, response.status)
    assert_equal({ errors: [{ base: ['Only administrative contacts can manage registry locks'] }] },
                 response_json)
  end

  def test_registrant_can_lock_a_domain
    post '/api/v1/registrant/domains/1b3ee442-e8fe-4922-9492-8fcb9dccc69c/registry_lock',
         {}, @auth_headers

    assert_equal(200, response.status)
    response_json = JSON.parse(response.body, symbolize_names: true)

    assert(response_json[:statuses].include?(DomainStatus::SERVER_DELETE_PROHIBITED))
    assert(response_json[:statuses].include?(DomainStatus::SERVER_TRANSFER_PROHIBITED))
    assert(response_json[:statuses].include?(DomainStatus::SERVER_UPDATE_PROHIBITED))
  end

  private

  def auth_token
    token_creator = AuthTokenCreator.create_with_defaults(@user)
    hash = token_creator.token_in_hash
    "Bearer #{hash[:access_token]}"
  end
end
