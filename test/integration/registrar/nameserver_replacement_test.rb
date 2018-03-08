require 'test_helper'

class RegistrarNameserverReplacementTest < ActionDispatch::IntegrationTest
  def setup
    WebMock.reset!
    login_as users(:api_goodnames)
  end

  def test_replaces_current_registrar_nameservers
    request_body = { data: { type: 'nameserver',
                             id: 'ns1.bestnames.test',
                             attributes: { hostname: 'new-ns.bestnames.test',
                                           ipv4: %w[192.0.2.55 192.0.2.56],
                                           ipv6: %w[2001:db8::55 2001:db8::56] } } }
    request_stub = stub_request(:put, /registrar\/nameservers/).with(body: request_body,
                                                                     headers: { 'Content-type' => 'application/json' },
                                                                     basic_auth: ['test_goodnames', 'testtest'])
                     .to_return(body: { data: [{
                                                 type: 'nameserver',
                                                 id: 'new-ns.bestnames.test'
                                               }] }.to_json, status: 200)

    visit registrar_domains_url
    click_link 'Replace nameserver'

    fill_in 'Old hostname', with: 'ns1.bestnames.test'
    fill_in 'New hostname', with: 'new-ns.bestnames.test'
    fill_in 'ipv4', with: "192.0.2.55\n192.0.2.56"
    fill_in 'ipv6', with: "2001:db8::55\n2001:db8::56"
    click_on 'Replace nameserver'

    assert_requested request_stub
    assert_current_path registrar_domains_path
    assert_text 'Nameserver have been successfully replaced'
  end

  def test_fails_gracefully
    stub_request(:put, /registrar\/nameservers/).to_return(status: 400,
                                                           body: { errors: [{ title: 'epic fail' }] }.to_json,
                                                           headers: { 'Content-type' => 'application/json' })

    visit registrar_domains_url
    click_link 'Replace nameserver'

    fill_in 'Old hostname', with: 'old hostname'
    fill_in 'New hostname', with: 'new hostname'
    fill_in 'ipv4', with: 'ipv4'
    fill_in 'ipv6', with: 'ipv6'
    click_on 'Replace nameserver'

    assert_text 'epic fail'
    assert_field 'Old hostname', with: 'old hostname'
    assert_field 'New hostname', with: 'new hostname'
    assert_field 'ipv4', with: 'ipv4'
    assert_field 'ipv6', with: 'ipv6'
  end
end
