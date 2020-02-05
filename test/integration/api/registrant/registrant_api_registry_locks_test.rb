require 'test_helper'
require 'auth_token/auth_token_creator'

class RegistrantApiRegistryLocksTest < ApplicationIntegrationTest
  def setup
    super

    @user = users(:registrant)
    @domain = domains(:airport)
    @auth_headers = { 'HTTP_AUTHORIZATION' => auth_token }
  end

  def test_can_lock_a_not_locked_domain
    post '/api/v1/registrant/domains/2df2c1a1-8f6a-490a-81be-8bdf29866880/registry_lock',
         headers: @auth_headers

    response_json = JSON.parse(response.body, symbolize_names: true)

    assert(response_json[:statuses].include?(DomainStatus::SERVER_DELETE_PROHIBITED))
    assert(response_json[:statuses].include?(DomainStatus::SERVER_TRANSFER_PROHIBITED))
    assert(response_json[:statuses].include?(DomainStatus::SERVER_UPDATE_PROHIBITED))

    @domain.reload
    assert(@domain.locked_by_registrant?)
  end

  def test_locking_a_domain_creates_a_version_record
    assert_difference '@domain.versions.count', 2 do
      post '/api/v1/registrant/domains/2df2c1a1-8f6a-490a-81be-8bdf29866880/registry_lock',
           headers: @auth_headers
    end

    @domain.reload
    assert_equal(@domain.updator, @user)
  end

  def test_cannot_lock_a_domain_in_pending_state
    @domain.statuses << DomainStatus::PENDING_UPDATE
    @domain.save

    post '/api/v1/registrant/domains/2df2c1a1-8f6a-490a-81be-8bdf29866880/registry_lock',
         headers: @auth_headers

    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal(422, response.status)
    assert_equal({ errors: [{ base: ['Domain cannot be locked'] }] }, response_json)
  end

  def test_cannot_lock_an_already_locked_domain
    @domain.apply_registry_lock
    assert(@domain.locked_by_registrant?)

    post '/api/v1/registrant/domains/2df2c1a1-8f6a-490a-81be-8bdf29866880/registry_lock',
         headers: @auth_headers

    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal(422, response.status)
    assert_equal({ errors: [{ base: ['Domain cannot be locked'] }] }, response_json)
  end

  def test_can_unlock_a_locked_domain
    @domain.apply_registry_lock

    delete '/api/v1/registrant/domains/2df2c1a1-8f6a-490a-81be-8bdf29866880/registry_lock',
           headers: @auth_headers

    response_json = JSON.parse(response.body, symbolize_names: true)
    assert(response_json[:statuses].include?(DomainStatus::OK))
    refute(response_json[:locked_by_registrant_at])
    @domain.reload
    refute(@domain.locked_by_registrant?)
  end

  def test_cannot_unlock_a_not_locked_domain
    delete '/api/v1/registrant/domains/2df2c1a1-8f6a-490a-81be-8bdf29866880/registry_lock',
           headers: @auth_headers

    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal(422, response.status)
    assert_equal({ errors: [{ base: ['Domain is not locked'] }] }, response_json)
  end

  def test_returns_404_when_domain_is_not_found
    post '/api/v1/registrant/domains/random-uuid/registry_lock', headers: @auth_headers

    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal(404, response.status)
    assert_equal({ errors: [{ base: ['Domain not found'] }] }, response_json)
  end

  def test_technical_contact_cannot_lock_a_domain
    domain = domains(:shop)
    contact = contacts(:john)
    domain.update!(registrant: contacts(:william).becomes(Registrant))
    domain.tech_contacts = [contact]
    domain.admin_contacts.clear
    assert_equal 'US-1234', @user.registrant_ident
    assert_equal '1234', contact.ident
    assert_equal 'US', contact.ident_country_code

    post api_v1_registrant_domain_registry_lock_path(domain.uuid), headers: @auth_headers

    assert_response :unauthorized
    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal({ errors: [{ base: ['Only administrative contacts can manage registry locks'] }] },
                 response_json)
  end

  def test_registrant_can_lock_a_domain
    post '/api/v1/registrant/domains/1b3ee442-e8fe-4922-9492-8fcb9dccc69c/registry_lock',
         headers: @auth_headers

    assert_equal(200, response.status)
    response_json = JSON.parse(response.body, symbolize_names: true)

    assert(response_json[:statuses].include?(DomainStatus::SERVER_DELETE_PROHIBITED))
    assert(response_json[:statuses].include?(DomainStatus::SERVER_TRANSFER_PROHIBITED))
    assert(response_json[:statuses].include?(DomainStatus::SERVER_UPDATE_PROHIBITED))
  end

  def test_locking_domains_returns_serialized_domain_object
    travel_to Time.zone.parse('2010-07-05')
    assert_equal 'Best Names', @domain.registrar.name
    assert_equal 'https://bestnames.test', @domain.registrar.website

    post '/api/v1/registrant/domains/1b3ee442-e8fe-4922-9492-8fcb9dccc69c/registry_lock',
         headers: @auth_headers

    assert_equal(200, response.status)
    response_json = JSON.parse(response.body, symbolize_names: true)

    assert_equal({ name: 'Best Names', website: 'https://bestnames.test' }, response_json[:registrar])
    assert_equal({name: 'John', id: 'eb2f2766-b44c-4e14-9f16-32ab1a7cb957'}, response_json[:registrant])
    assert_equal([{name: 'Jane', id: '9db3de62-2414-4487-bee2-d5c155567768'}], response_json[:admin_contacts])
    assert_equal([{name: 'William', id: '0aa54704-d6f7-4ca9-b8ca-2827d9a4e4eb'},
                  {name: 'Acme Ltd', id: 'f1dd365c-5be9-4b3d-a44e-3fa002465e4d'}].to_set,
                 response_json[:tech_contacts].to_set)
    assert_equal(
      [{hostname: 'ns1.bestnames.test', ipv4: ['192.0.2.1'], ipv6: ['2001:db8::1']},
       {hostname: 'ns2.bestnames.test', ipv4: ['192.0.2.2'], ipv6: ['2001:db8::2']}].to_set,
                 response_json[:nameservers].to_set)
    assert_equal(Time.zone.parse('2010-07-05'), response_json[:locked_by_registrant_at])
  end

  private

  def auth_token
    token_creator = AuthTokenCreator.create_with_defaults(@user)
    hash = token_creator.token_in_hash
    "Bearer #{hash[:access_token]}"
  end
end
