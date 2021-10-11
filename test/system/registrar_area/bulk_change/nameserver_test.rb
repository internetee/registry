require 'application_system_test_case'

class RegistrarAreaNameserverBulkChangeTest < ApplicationSystemTestCase
  setup do
    sign_in users(:api_goodnames)
    Capybara.default_max_wait_time = 10
  end

  def test_replaces_current_registrar_nameservers
    request_body = { data: { type: 'nameserver',
                             id: 'ns1.bestnames.test',
                             domains: [],
                             attributes: { hostname: 'new-ns.bestnames.test',
                                           ipv4: %w[192.0.2.55 192.0.2.56],
                                           ipv6: %w[2001:db8::55 2001:db8::56] } } }
    request_stub = stub_request(:put, /registrar\/nameservers/).with(body: request_body,
                                                                     headers: { 'Content-type' => Mime[:json] },
                                                                     basic_auth: ['test_goodnames', 'testtest'])
                     .to_return(body: { data: {
                                            type: 'nameserver',
                                            id: 'new-ns.bestnames.test',
                                            affected_domains: ["airport.test", "shop.test"],
                                            skipped_domains: []
                                        }
                                      }.to_json, status: 200)

    visit registrar_domains_url
    click_link 'Bulk change'
    click_link 'Nameserver'

    fill_in 'Old hostname (optional)', with: 'ns1.bestnames.test'
    fill_in 'New hostname', with: 'new-ns.bestnames.test'
    fill_in 'ipv4', with: "192.0.2.55\n192.0.2.56"
    fill_in 'ipv6', with: "2001:db8::55\n2001:db8::56"
    click_on 'Replace/Add nameserver'

    assert_requested request_stub
    assert_current_path registrar_domains_path
    assert_text 'Nameserver have been successfully replaced'
    assert_text 'Affected domains: airport.test, shop.test'
  end

  def test_fails_gracefully
    stub_request(:put, /registrar\/nameservers/).to_return(status: 400,
                                                           body: { message: 'epic fail' }.to_json,
                                                           headers: { 'Content-type' => Mime[:json] })

    visit registrar_domains_url
    click_link 'Bulk change'
    click_link 'Nameserver'

    fill_in 'Old hostname', with: 'old hostname'
    fill_in 'New hostname', with: 'new hostname'
    fill_in 'ipv4', with: 'ipv4'
    fill_in 'ipv6', with: 'ipv6'
    click_on 'Replace/Add nameserver'

    assert_text 'epic fail'
    assert_field 'Old hostname', with: 'old hostname'
    assert_field 'New hostname', with: 'new hostname'
    assert_field 'ipv4', with: 'ipv4'
    assert_field 'ipv6', with: 'ipv6'
  end

  def test_replaces_nameservers_only_for_scoped_domains
    request_body = { data: { type: 'nameserver',
                             id: 'ns1.bestnames.test',
                             domains: ['shop.test'],
                             attributes: { hostname: 'new-ns.bestnames.test',
                                           ipv4: %w[192.0.2.55 192.0.2.56],
                                           ipv6: %w[2001:db8::55 2001:db8::56] } } }
    request_stub = stub_request(:put, /registrar\/nameservers/).with(body: request_body,
                                                                     headers: { 'Content-type' => Mime[:json] },
                                                                     basic_auth: ['test_goodnames', 'testtest'])
                   .to_return(body: { data: {
                     type: 'nameserver',
                     id: 'new-ns.bestnames.test',
                     affected_domains: ["shop.test"],
                     skipped_domains: []}}.to_json, status: 200)

    visit registrar_domains_url
    click_link 'Bulk change'
    click_link 'Nameserver'

    fill_in 'Old hostname', with: 'ns1.bestnames.test'
    fill_in 'New hostname', with: 'new-ns.bestnames.test'
    fill_in 'ipv4', with: "192.0.2.55\n192.0.2.56"
    fill_in 'ipv6', with: "2001:db8::55\n2001:db8::56"
    attach_file :puny_file, Rails.root.join('test', 'fixtures', 'files', 'valid_domains_for_ns_replacement.csv').to_s

    click_on 'Replace/Add nameserver'

    assert_requested request_stub
    assert_current_path registrar_domains_path
    assert_text 'Nameserver have been successfully replaced'
    assert_text 'Affected domains: shop.test'
  end

  def test_replaces_nameservers_with_invalid_domains_list
    nameserver = nameservers(:shop_ns1)

    visit registrar_domains_url
    click_link 'Bulk change'
    click_link 'Nameserver'

    fill_in 'Old hostname', with: nameserver.hostname
    fill_in 'New hostname', with: 'new-ns.bestnames.test'
    fill_in 'ipv4', with: "192.0.2.55\n192.0.2.56"
    fill_in 'ipv6', with: "2001:db8::55\n2001:db8::56"
    attach_file :puny_file, Rails.root.join('test', 'fixtures', 'files', 'invalid_domains_for_ns_replacement.csv').to_s

    assert_no_changes -> { nameserver.hostname } do
      click_on 'Replace/Add nameserver'
    end

    assert_current_path registrar_domains_path
    assert_text 'CSV scoped domain list seems empty. Make sure that domains are added and "Domain" header is present.'
  end

  def test_adding_current_registrar_nameservers
    request_body = { data: { type: 'nameserver',
                             id: '',
                             domains: [],
                             attributes: { hostname: 'new-ns2.bestnames.test',
                                           ipv4: %w[192.0.2.55 192.0.2.56],
                                           ipv6: %w[2001:db8::55 2001:db8::56] } } }
    request_stub = stub_request(:put, /registrar\/nameservers/).with(body: request_body,
                                                                     headers: { 'Content-type' => Mime[:json] },
                                                                     basic_auth: ['test_goodnames', 'testtest'])
                                                               .to_return(body: { data: {
                                                                 type: 'nameserver',
                                                                 id: 'new-ns2.bestnames.test',
                                                                 affected_domains: ["airport.test", "shop.test"],
                                                                 skipped_domains: []
                                                               }
                                                               }.to_json, status: 200)

    visit registrar_domains_url
    click_link 'Bulk change'
    click_link 'Nameserver'

    fill_in 'New hostname', with: 'new-ns2.bestnames.test'
    fill_in 'ipv4', with: "192.0.2.55\n192.0.2.56"
    fill_in 'ipv6', with: "2001:db8::55\n2001:db8::56"
    click_on 'Replace/Add nameserver'

    assert_requested request_stub
    assert_current_path registrar_domains_path
    assert_text 'Nameserver have been successfully added'
    assert_text 'Affected domains: airport.test, shop.test'
  end

  def test_adding_nameservers_only_for_scoped_domains
    request_body = { data: { type: 'nameserver',
                             id: '',
                             domains: ['shop.test'],
                             attributes: { hostname: 'new-ns1.bestnames.test',
                                           ipv4: %w[192.0.2.55 192.0.2.56],
                                           ipv6: %w[2001:db8::55 2001:db8::56] } } }
    request_stub = stub_request(:put, /registrar\/nameservers/).with(body: request_body,
                                                                     headers: { 'Content-type' => Mime[:json] },
                                                                     basic_auth: ['test_goodnames', 'testtest'])
                                                               .to_return(body: { data: {
                                                                 type: 'nameserver',
                                                                 id: 'new-ns1.bestnames.test',
                                                                 affected_domains: ["shop.test"],
                                                                 skipped_domains: []}}.to_json, status: 200)

    visit registrar_domains_url
    click_link 'Bulk change'
    click_link 'Nameserver'

    fill_in 'New hostname', with: 'new-ns1.bestnames.test'
    fill_in 'ipv4', with: "192.0.2.55\n192.0.2.56"
    fill_in 'ipv6', with: "2001:db8::55\n2001:db8::56"
    attach_file :puny_file, Rails.root.join('test', 'fixtures', 'files', 'valid_domains_for_ns_replacement.csv').to_s

    click_on 'Replace/Add nameserver'

    assert_requested request_stub
    assert_current_path registrar_domains_path
    assert_text 'Nameserver have been successfully added'
    assert_text 'Affected domains: shop.test'
  end
end
