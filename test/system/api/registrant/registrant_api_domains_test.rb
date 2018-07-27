require 'test_helper'

class RegistrantApiDomainsTest < ApplicationSystemTestCase
  def setup
    super

    @domain = domains(:hospital)
    @registrant = @domain.registrant
  end

  def teardown
    super
  end

  def test_get_domain_details_by_uuid
    get '/api/v1/registrant/domains/5edda1a5-3548-41ee-8b65-6d60daf85a37'
    assert_equal(200, response.status)

    domain = JSON.parse(response.body, symbolize_names: true)
    assert_equal('hospital.test', domain[:name])
  end

  def test_get_non_existent_domain_details_by_uuid
    get '/api/v1/registrant/domains/random-uuid'
    assert_equal(404, response.status)

    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal({errors: ['Domain not found']}, response_json)
  end

  def test_get_non_registrar_domain_details_by_uuid
    # no op
  end
end
