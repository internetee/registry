require 'test_helper'
require 'auth_token/auth_token_creator'

class RegistrantApiDomainsTest < ApplicationIntegrationTest
  def setup
    super

    @domain = domains(:airport)
    @registrant = @domain.registrant
    @user = users(:registrant)
    domains(:metro).tech_domain_contacts.update(contact_id: @registrant.id)
    @auth_headers = { 'HTTP_AUTHORIZATION' => auth_token }
  end

  def test_get_domain_details_by_uuid
    get '/api/v1/registrant/domains/5edda1a5-3548-41ee-8b65-6d60daf85a37', headers: @auth_headers
    assert_equal(200, response.status)

    domain = JSON.parse(response.body, symbolize_names: true)

    assert_equal('hospital.test', domain[:name])
    assert_equal('5edda1a5-3548-41ee-8b65-6d60daf85a37', domain[:id])
    assert_equal({:name=>"John", 
                  :id=>"eb2f2766-b44c-4e14-9f16-32ab1a7cb957", 
                  :ident=>"1234", :ident_type=>"priv", 
                  :ident_country_code=>"US", 
                  :phone=>"+555.555", 
                  :email=>"john@inbox.test", 
                  :org=>false}, 
                  domain[:registrant])
    assert_equal([{name: 'John',
                   id: 'eb2f2766-b44c-4e14-9f16-32ab1a7cb957',
                   email: 'john@inbox.test'}],
                 domain[:admin_contacts])
    assert_equal([{name: 'John',
                   id: 'eb2f2766-b44c-4e14-9f16-32ab1a7cb957',
                   email: 'john@inbox.test'}],
                 domain[:tech_contacts])
    assert_equal({ name: 'Good Names', website: nil }, domain[:registrar])

    assert_equal([], domain[:nameservers])
    assert_equal([], domain[:dnssec_keys])
    assert(domain.has_key?(:dnssec_changed_at))

    assert(domain.has_key?(:locked_by_registrant_at))
  end

  def test_get_non_existent_domain_details_by_uuid
    get '/api/v1/registrant/domains/random-uuid', headers: @auth_headers
    assert_equal(404, response.status)

    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal({ errors: [base: ['Domain not found']] }, response_json)
  end

  def test_root_returns_domain_list
    get '/api/v1/registrant/domains', headers: @auth_headers
    assert_equal(200, response.status)

    response_json = JSON.parse(response.body, symbolize_names: true)
    array_of_domain_names = response_json[:domains].map { |x| x[:name] }
    assert(array_of_domain_names.include?('hospital.test'))

    array_of_domain_registrars = response_json[:domains].map { |x| x[:registrar] }
    assert(array_of_domain_registrars.include?({name: 'Good Names', website: nil}))
  end

  def test_return_domain_list_with_registrants_and_admins
    domains(:hospital).admin_domain_contacts.update(contact_id: contacts(:william).id)
    domains(:hospital).update(registrant: contacts(:william).becomes(Registrant)) 

    get '/api/v1/registrant/domains', headers: @auth_headers, params: { 'offset' => 0 }
    assert_equal(200, response.status)

    response_json = JSON.parse(response.body, symbolize_names: true)
    response_json[:domains].each do |x| 
      if x[:registrant][:org] == false
        x[:tech_contacts].each do |s|
          assert_not s[:name].include?(@registrant.name)
        end
      end
    end
  end

  def test_return_domain_list_with_registrants_and_admins_tech
    get '/api/v1/registrant/domains', headers: @auth_headers, params: { 'offset' => 0, 'tech' => true }
    assert_equal(200, response.status)

    response_json = JSON.parse(response.body, symbolize_names: true)
    response_json[:domains].each do |x| 
      if x[:name] == 'metro.test'
        x[:tech_contacts].each do |s|
            assert s[:name].include?(@registrant.name)
        end
      end
    end
  end  

  def test_domains_total_if_an_incomplete_list_is_returned
    get '/api/v1/registrant/domains', headers: @auth_headers, params: { 'offset' => 0 }
    assert_equal(200, response.status)

    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal response_json[:domains].length, response_json[:count]
    assert_equal response_json[:total], 5
  end

  def test_root_accepts_limit_and_offset_parameters
    get '/api/v1/registrant/domains', params: { 'limit' => 2, 'offset' => 0 },
        headers: @auth_headers
    response_json = JSON.parse(response.body, symbolize_names: true)

    assert_equal(200, response.status)
    assert_equal(4, response_json[:domains].count)

    get '/api/v1/registrant/domains', headers: @auth_headers
    response_json = JSON.parse(response.body, symbolize_names: true)

    assert_equal(4, response_json[:domains].count)
  end

  def test_root_does_not_accept_limit_higher_than_200
    get '/api/v1/registrant/domains', params: { 'limit' => 400, 'offset' => 0 },
        headers: @auth_headers

    assert_equal(400, response.status)
    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal({ errors: [{ limit: ['parameter is out of range'] }] }, response_json)
  end

  def test_root_does_not_accept_offset_lower_than_0
    get '/api/v1/registrant/domains', params: { 'limit' => 100, 'offset' => "-10" },
        headers: @auth_headers

    assert_equal(400, response.status)
    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal({ errors: [{ offset: ['parameter is out of range'] }] }, response_json)
  end

  def test_root_returns_401_without_authorization
    get '/api/v1/registrant/domains'
    assert_equal(401, response.status)
    json_body = JSON.parse(response.body, symbolize_names: true)

    assert_equal({ errors: [base: ['Not authorized']] }, json_body)
  end

  def test_details_returns_401_without_authorization
    get '/api/v1/registrant/domains/5edda1a5-3548-41ee-8b65-6d60daf85a37'
    assert_equal(401, response.status)
    json_body = JSON.parse(response.body, symbolize_names: true)

    assert_equal({ errors: [base: ['Not authorized']] }, json_body)
  end

  private

  def auth_token
    token_creator = AuthTokenCreator.create_with_defaults(@user)
    hash = token_creator.token_in_hash
    "Bearer #{hash[:access_token]}"
  end
end
