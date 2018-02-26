require 'test_helper'

class APINameserversPutTest < ActionDispatch::IntegrationTest
  def test_replaces_current_registrar_nameservers
    request_params = { format: :json, data: { type: 'nameserver', id: 'ns1.bestnames.test',
                                              attributes: { hostname: 'ns55.bestnames.test',
                                                            ipv4: ['192.0.2.55'],
                                                            ipv6: ['2001:db8::55'] } } }
    put '/repp/v1/registrar/nameservers', request_params, { 'HTTP_AUTHORIZATION' => http_auth_key }

    new_nameserver = registrars(:bestnames).nameservers.find_by(hostname: 'ns55.bestnames.test')
    assert_nil registrars(:bestnames).nameservers.find_by(hostname: 'ns1.bestnames.test')
    assert_equal ['192.0.2.55'], new_nameserver.ipv4
    assert_equal ['2001:DB8::55'], new_nameserver.ipv6
    assert_response 200
    assert_equal ({ data: { type: 'nameserver',
                            id: 'ns55.bestnames.test',
                            attributes: { hostname: 'ns55.bestnames.test',
                                          ipv4: ['192.0.2.55'],
                                          ipv6: ['2001:db8::55'] } } }),
                 JSON.parse(response.body, symbolize_names: true)
  end

  def test_honors_optional_params
    request_params = { format: :json, data: { type: 'nameserver', id: 'ns1.bestnames.test',
                                              attributes: { hostname: 'ns55.bestnames.test' } } }
    put '/repp/v1/registrar/nameservers', request_params, { 'HTTP_AUTHORIZATION' => http_auth_key }
    assert_response 200
  end

  def test_non_existent_nameserver_hostname
    request_params = { format: :json, data: { type: 'nameserver', id: 'non-existent.test',
                                              attributes: { hostname: 'any.bestnames.test' } } }
    put '/repp/v1/registrar/nameservers', request_params, { 'HTTP_AUTHORIZATION' => http_auth_key }

    assert_response 404
    assert_equal ({ errors: [{ title: 'Hostname non-existent.test does not exist' }] }),
                 JSON.parse(response.body, symbolize_names: true)
  end

  def test_invalid_request_params
    request_params = { format: :json, data: { type: 'nameserver', id: 'ns1.bestnames.test',
                                              attributes: { hostname: '' } } }
    put '/repp/v1/registrar/nameservers', request_params, { 'HTTP_AUTHORIZATION' => http_auth_key }

    assert_response 400
    assert_equal ({ errors: [{ title: 'Invalid params' }] }),
                 JSON.parse(response.body, symbolize_names: true)
  end

  def test_unauthenticated
    put '/repp/v1/registrar/nameservers'
    assert_response 401
  end

  private

  def http_auth_key
    ActionController::HttpAuthentication::Basic.encode_credentials('test_bestnames', 'testtest')
  end
end
