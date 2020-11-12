require 'test_helper'
require 'auth_token/auth_token_creator'

class RegistrantApiVerificationsTest < ApplicationIntegrationTest
  def setup
    super

    @domain = domains(:hospital)
    @registrant = @domain.registrant
    @new_registrant = contacts(:jack)
    @user = users(:api_bestnames)

    @token = 'verysecrettoken'

    @domain.update!(statuses: [DomainStatus::PENDING_UPDATE],
      registrant_verification_asked_at: Time.zone.now - 1.day,
      registrant_verification_token: @token)

  end

  def test_fetches_registrant_change_request
    pending_json = { new_registrant_id: @new_registrant.id,
      new_registrant_name: @new_registrant.name,
      new_registrant_email: @new_registrant.email,
      current_user_id: @user.id }

    @domain.update(pending_json: pending_json)
    @domain.reload

    assert @domain.registrant_update_confirmable?(@token)

    get "/api/v1/registrant/confirms/#{@domain.name_puny}/change/#{@token}"
    assert_equal(200, response.status)

    res = JSON.parse(response.body, symbolize_names: true)
    expected_body = {
      domain_name: "hospital.test",
      current_registrant: {
        name: @registrant.name,
        ident: @registrant.ident,
        country: @registrant.ident_country_code
      },
      new_registrant: {
        name: @new_registrant.name,
        ident: @new_registrant.ident,
        country: @new_registrant.ident_country_code
      }
    }

    assert_equal expected_body, res
  end

  def test_approves_registrant_change_request
  pending_json = { new_registrant_id: @new_registrant.id,
    new_registrant_name: @new_registrant.name,
    new_registrant_email: @new_registrant.email,
    current_user_id: @user.id }

    @domain.update!(pending_json: pending_json)
    @domain.reload

    assert @domain.registrant_update_confirmable?(@token)

    perform_enqueued_jobs do
      post "/api/v1/registrant/confirms/#{@domain.name_puny}/change/#{@token}/confirmed"
      assert_equal(200, response.status)

      res = JSON.parse(response.body, symbolize_names: true)
      expected_body = {
        domain_name: @domain.name,
        current_registrant: {
          name: @new_registrant.name,
          ident: @new_registrant.ident,
          country: @new_registrant.ident_country_code
        },
        status: 'confirmed'
      }
      assert_equal expected_body, res
    end
  end

  def test_rejects_registrant_change_request
    pending_json = { new_registrant_id: @new_registrant.id,
      new_registrant_name: @new_registrant.name,
      new_registrant_email: @new_registrant.email,
      current_user_id: @user.id }

    @domain.update(pending_json: pending_json)
    @domain.reload

    assert @domain.registrant_update_confirmable?(@token)

    post "/api/v1/registrant/confirms/#{@domain.name_puny}/change/#{@token}/rejected"
    assert_equal(200, response.status)

    res = JSON.parse(response.body, symbolize_names: true)
    expected_body = {
      domain_name: @domain.name,
      current_registrant: {
        name: @registrant.name,
        ident: @registrant.ident,
        country: @registrant.ident_country_code
      },
      status: 'rejected'
    }

    assert_equal expected_body, res
  end

  def test_registrant_change_requires_valid_attributes
  pending_json = { new_registrant_id: @new_registrant.id,
    new_registrant_name: @new_registrant.name,
    new_registrant_email: @new_registrant.email,
    current_user_id: @user.id }

    @domain.update(pending_json: pending_json)
    @domain.reload

    get "/api/v1/registrant/confirms/#{@domain.name_puny}/change/123"
    assert_equal 401, response.status

    get "/api/v1/registrant/confirms/aohldfjg.ee/change/123"
    assert_equal 404, response.status

    post "/api/v1/registrant/confirms/#{@domain.name_puny}/change/#{@token}/invalidaction"
    assert_equal 404, response.status
  end

  def test_fetches_domain_delete_request
    pending_json = { new_registrant_id: @new_registrant.id,
    new_registrant_name: @new_registrant.name,
    new_registrant_email: @new_registrant.email,
    current_user_id: @user.id }

    @domain.update(pending_json: pending_json, statuses: [DomainStatus::PENDING_DELETE_CONFIRMATION])
    @domain.reload

    assert @domain.registrant_delete_confirmable?(@token)

    get "/api/v1/registrant/confirms/#{@domain.name_puny}/delete/#{@token}"
    assert_equal(200, response.status)

    res = JSON.parse(response.body, symbolize_names: true)
    expected_body = {
      domain_name: "hospital.test",
      current_registrant: {
        name: @registrant.name,
        ident: @registrant.ident,
        country: @registrant.ident_country_code
      }
    }

    assert_equal expected_body, res
  end

  def test_approves_domain_delete_request
    pending_json = { new_registrant_id: @new_registrant.id,
      new_registrant_name: @new_registrant.name,
      new_registrant_email: @new_registrant.email,
      current_user_id: @user.id }

      @domain.update(pending_json: pending_json, statuses: [DomainStatus::PENDING_DELETE_CONFIRMATION])
      @domain.reload

    assert @domain.registrant_delete_confirmable?(@token)

    post "/api/v1/registrant/confirms/#{@domain.name_puny}/delete/#{@token}/confirmed"
    assert_equal(200, response.status)

    res = JSON.parse(response.body, symbolize_names: true)
    expected_body = {
      domain_name: @domain.name,
      current_registrant: {
        name: @registrant.name,
        ident: @registrant.ident,
        country: @registrant.ident_country_code
      },
      status: 'confirmed'
    }

    assert_equal expected_body, res
  end

  def test_rejects_domain_delete_request
    pending_json = { new_registrant_id: @new_registrant.id,
      new_registrant_name: @new_registrant.name,
      new_registrant_email: @new_registrant.email,
      current_user_id: @user.id }

      @domain.update(pending_json: pending_json, statuses: [DomainStatus::PENDING_DELETE_CONFIRMATION])
      @domain.reload

    assert @domain.registrant_delete_confirmable?(@token)

    post "/api/v1/registrant/confirms/#{@domain.name_puny}/delete/#{@token}/rejected"
    assert_equal(200, response.status)

    res = JSON.parse(response.body, symbolize_names: true)
    expected_body = {
      domain_name: @domain.name,
      current_registrant: {
        name: @registrant.name,
        ident: @registrant.ident,
        country: @registrant.ident_country_code
      },
      status: 'rejected'
    }

    assert_equal expected_body, res
  end

  def test_domain_delete_requires_valid_attributes
    pending_json = { new_registrant_id: @new_registrant.id,
      new_registrant_name: @new_registrant.name,
      new_registrant_email: @new_registrant.email,
      current_user_id: @user.id }

    @domain.update(pending_json: pending_json, statuses: [DomainStatus::PENDING_DELETE_CONFIRMATION])
    @domain.reload

    get "/api/v1/registrant/confirms/#{@domain.name_puny}/delete/123"
    assert_equal 401, response.status

    get "/api/v1/registrant/confirms/aohldfjg.ee/delete/123"
    assert_equal 404, response.status

    post "/api/v1/registrant/confirms/#{@domain.name_puny}/delete/#{@token}/invalidaction"
    assert_equal 404, response.status
  end
  #def test_get_non_existent_domain_details_by_uuid
  #  get '/api/v1/registrant/domains/random-uuid', headers: @auth_headers
  #  assert_equal(404, response.status)

  #  response_json = JSON.parse(response.body, symbolize_names: true)
  #  assert_equal({ errors: [base: ['Domain not found']] }, response_json)
  #end

  #def test_root_returns_domain_list
  #  get '/api/v1/registrant/domains', headers: @auth_headers
  #  assert_equal(200, response.status)

  #  response_json = JSON.parse(response.body, symbolize_names: true)
  #  array_of_domain_names = response_json.map { |x| x[:name] }
  #  assert(array_of_domain_names.include?('hospital.test'))

  #  array_of_domain_registrars = response_json.map { |x| x[:registrar] }
  #  assert(array_of_domain_registrars.include?({name: 'Good Names', website: nil}))
  #end

  #def test_root_accepts_limit_and_offset_parameters
  #  get '/api/v1/registrant/domains', params: { 'limit' => 2, 'offset' => 0 },
  #      headers: @auth_headers
  #  response_json = JSON.parse(response.body, symbolize_names: true)

  #  assert_equal(200, response.status)
  #  assert_equal(2, response_json.count)

  #  get '/api/v1/registrant/domains', headers: @auth_headers
  #  response_json = JSON.parse(response.body, symbolize_names: true)

  #  assert_equal(4, response_json.count)
  #end

  #def test_root_does_not_accept_limit_higher_than_200
  #  get '/api/v1/registrant/domains', params: { 'limit' => 400, 'offset' => 0 },
  #      headers: @auth_headers

  #  assert_equal(400, response.status)
  #  response_json = JSON.parse(response.body, symbolize_names: true)
  #  assert_equal({ errors: [{ limit: ['parameter is out of range'] }] }, response_json)
  #end

  #def test_root_does_not_accept_offset_lower_than_0
  #  get '/api/v1/registrant/domains', params: { 'limit' => 200, 'offset' => "-10" },
  #      headers: @auth_headers

  #  assert_equal(400, response.status)
  #  response_json = JSON.parse(response.body, symbolize_names: true)
  #  assert_equal({ errors: [{ offset: ['parameter is out of range'] }] }, response_json)
  #end

  #def test_root_returns_401_without_authorization
  #  get '/api/v1/registrant/domains'
  #  assert_equal(401, response.status)
  #  json_body = JSON.parse(response.body, symbolize_names: true)

  #  assert_equal({ errors: [base: ['Not authorized']] }, json_body)
  #end

  #def test_details_returns_401_without_authorization
  #  get '/api/v1/registrant/domains/5edda1a5-3548-41ee-8b65-6d60daf85a37'
  #  assert_equal(401, response.status)
  #  json_body = JSON.parse(response.body, symbolize_names: true)

  #  assert_equal({ errors: [base: ['Not authorized']] }, json_body)
  #end
end
