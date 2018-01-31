require 'test_helper'

class APIPutNameserversTest < ActionDispatch::IntegrationTest
  def test_changes_nameservers_of_all_domains_of_current_registrar
    ns2 = domains(:shop).nameservers.find_by(hostname: 'ns2.bestnames.test')
    request_params = { format: :json, data: { type: 'nameservers', id: 'ns2.bestnames.test',
                                              attributes: { hostname: 'ns3.bestnames.test',
                                                            ipv4: ['192.0.2.3'],
                                                            ipv6: ['2001:DB8::3'] } } }
    put '/repp/v1/nameservers', request_params, { 'HTTP_AUTHORIZATION' => http_auth_key }
    ns2.reload
    assert_equal 'ns3.bestnames.test', ns2.hostname
    assert_equal ['192.0.2.3'], ns2.ipv4
    assert_equal ['2001:DB8::3'], ns2.ipv6
    assert_response 204
    assert_empty response.body
  end

  def test_unauthenticated
    put '/repp/v1/nameservers'
    assert_response 401
  end

  private

  def http_auth_key
    ActionController::HttpAuthentication::Basic.encode_credentials('test_bestnames', 'testtest')
  end
end
