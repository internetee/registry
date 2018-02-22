require 'test_helper'

class RegistrarDomainTransfersTest < ActionDispatch::IntegrationTest
  def setup
    WebMock.reset!
    login_as users(:api_goodnames)
  end

  def test_batch_transfer_succeeds
    request_body = { data: { domainTransfers: [{ domainName: 'shop.test', transferCode: '65078d5' }] } }
    headers = { 'Content-type' => 'application/json' }
    request_stub = stub_request(:post, /domain_transfers/).with(body: request_body,
                                                                headers: headers,
                                                                basic_auth: ['test_goodnames', 'testtest'])
                     .to_return(body: { data: [{
                                                 type: 'domain_transfer'
                                               }] }.to_json, status: 200)

    visit registrar_domains_url
    click_link 'Transfer'

    click_on 'Batch'
    attach_file 'Batch file', Rails.root.join('test', 'fixtures', 'files', 'valid_domains_for_transfer.csv').to_s
    click_button 'Transfer batch'

    assert_requested request_stub
    assert_current_path registrar_domains_path
    assert_text 'Domains have been successfully transferred'
  end

  def test_batch_transfer_fails_gracefully
    body = { errors: [{ title: 'epic fail' }] }.to_json
    headers = { 'Content-type' => 'application/json' }
    stub_request(:post, /domain_transfers/).to_return(status: 400, body: body, headers: headers)

    visit registrar_domains_url
    click_link 'Transfer'

    click_on 'Batch'
    attach_file 'Batch file', Rails.root.join('test', 'fixtures', 'files', 'valid_domains_for_transfer.csv').to_s
    click_button 'Transfer batch'

    assert_text 'epic fail'
  end
end
