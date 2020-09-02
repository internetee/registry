require 'application_system_test_case'

class RegistrarAreaBulkTransferTest < ApplicationSystemTestCase
  setup do
    sign_in users(:api_goodnames)
  end

  def test_transfer_multiple_domains_in_bulk
    request_body = { data: { domainTransfers: [{ domainName: 'shop.test', transferCode: '65078d5' }] } }
    headers = { 'Content-type' => Mime[:json] }
    request_stub = stub_request(:post, /domain_transfers/).with(body: request_body,
                                                                headers: headers,
                                                                basic_auth: ['test_goodnames', 'testtest'])
                     .to_return(body: { data: [{
                                                 type: 'domain_transfer'
                                               }] }.to_json, status: 200)

    visit registrar_domains_url
    click_link 'Bulk change'
    click_link 'Bulk transfer'
    attach_file 'Batch file', Rails.root.join('test', 'fixtures', 'files', 'valid_domains_for_transfer.csv').to_s
    click_button 'Transfer'

    assert_requested request_stub
    assert_current_path registrar_domains_path
    assert_text '1 domains have been successfully transferred'
  end

  def test_fail_gracefully
    body = { errors: [{ title: 'epic fail' }] }.to_json
    headers = { 'Content-type' => Mime[:json] }
    stub_request(:post, /domain_transfers/).to_return(status: 400, body: body, headers: headers)

    visit registrar_domains_url
    click_link 'Bulk change'
    click_link 'Bulk transfer'
    attach_file 'Batch file', Rails.root.join('test', 'fixtures', 'files', 'valid_domains_for_transfer.csv').to_s
    click_button 'Transfer'

    assert_text 'epic fail'
  end
end
