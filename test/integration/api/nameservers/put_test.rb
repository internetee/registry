require 'test_helper'

class APINameserversPutTest < ApplicationIntegrationTest
  def test_replaces_registrar_nameservers
    old_nameserver_ids = [nameservers(:shop_ns1).id,
                          nameservers(:airport_ns1).id,
                          nameservers(:metro_ns1).id]
    request_params = { format: :json, data: { type: 'nameserver', id: 'ns1.bestnames.test',
                                              attributes: { hostname: 'ns55.bestnames.test' } } }
    put '/repp/v1/registrar/nameservers', request_params, { 'HTTP_AUTHORIZATION' => http_auth_key }
    assert_empty (old_nameserver_ids & registrars(:bestnames).nameservers(true).ids)
  end

  def test_saves_all_attributes
    request_params = { format: :json, data: { type: 'nameserver', id: 'ns1.bestnames.test',
                                              attributes: { hostname: 'ns55.bestnames.test',
                                                            ipv4: ['192.0.2.55'],
                                                            ipv6: ['2001:db8::55'] } } }
    put '/repp/v1/registrar/nameservers', request_params, { 'HTTP_AUTHORIZATION' => http_auth_key }

    new_nameserver = domains(:shop).nameservers.find_by(hostname: 'ns55.bestnames.test')
    assert_equal ['192.0.2.55'], new_nameserver.ipv4
    assert_equal ['2001:DB8::55'], new_nameserver.ipv6
  end

  def test_keeps_other_nameserver_intact
    request_params = { format: :json, data: { type: 'nameserver', id: 'ns1.bestnames.test',
                                              attributes: { hostname: 'ns55.bestnames.test' } } }

    other_nameserver_hash = nameservers(:shop_ns2).attributes
    put '/repp/v1/registrar/nameservers', request_params, { 'HTTP_AUTHORIZATION' => http_auth_key }
    assert_equal other_nameserver_hash, nameservers(:shop_ns2).reload.attributes
  end

  def test_keeps_other_registrar_nameservers_intact
    request_params = { format: :json, data: { type: 'nameserver', id: 'ns1.bestnames.test',
                                              attributes: { hostname: 'ns55.bestnames.test' } } }

    nameserver_hash = nameservers(:metro_ns1).attributes
    put '/repp/v1/registrar/nameservers', request_params, { 'HTTP_AUTHORIZATION' => http_auth_key }
    assert_equal nameserver_hash, nameservers(:metro_ns1).reload.attributes
  end

  def test_returns_new_nameserver_record_and_affected_domain
    request_params = { format: :json, data: { type: 'nameserver', id: 'ns1.bestnames.test',
                                              attributes: { hostname: 'ns55.bestnames.test',
                                                            ipv4: ['192.0.2.55'],
                                                            ipv6: ['2001:db8::55'] } } }

    put '/repp/v1/registrar/nameservers', request_params, { 'HTTP_AUTHORIZATION' => http_auth_key }

    assert_response 200
    assert_equal ({ data: { type: 'nameserver',
                            id: 'ns55.bestnames.test',
                            attributes: { hostname: 'ns55.bestnames.test',
                                          ipv4: ['192.0.2.55'],
                                          ipv6: ['2001:db8::55'] }},
                    affected_domains: ["airport.test", "shop.test"] }),
                 JSON.parse(response.body, symbolize_names: true)
  end

  def test_optional_params
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
    assert_equal ({ errors: [{ title: 'Hostname is missing' }] }),
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
