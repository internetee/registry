require 'test_helper'

class Repp::DomainTransfersTest < ActionDispatch::IntegrationTest
  def test_transfers_domain
    request_params = { format: :json,
                       data: { domainTransfers: [{ domainName: 'shop.test', transferCode: '65078d5' }] } }
    post '/repp/v1/domain_transfers', request_params, { 'HTTP_AUTHORIZATION' => http_auth_key }
    assert_response 204
    assert_equal registrars(:goodnames), domains(:shop).registrar
    assert_empty response.body
  end

  def test_fails_if_domain_does_not_exist
    request_params = { format: :json,
                       data: { domainTransfers: [{ domainName: 'non-existent.test', transferCode: 'any' }] } }
    post '/repp/v1/domain_transfers', request_params, { 'HTTP_AUTHORIZATION' => http_auth_key }
    assert_response 400
    assert_equal ({ errors: [{ title: 'non-existent.test does not exist' }] }),
                 JSON.parse(response.body, symbolize_names: true)
  end

  def test_fails_if_transfer_code_is_wrong
    request_params = { format: :json,
                       data: { domainTransfers: [{ domainName: 'shop.test', transferCode: 'wrong' }] } }
    post '/repp/v1/domain_transfers', request_params, { 'HTTP_AUTHORIZATION' => http_auth_key }
    assert_response 400
    refute_equal registrars(:goodnames), domains(:shop).registrar
    assert_equal ({ errors: [{ title: 'shop.test transfer code is wrong' }] }),
                 JSON.parse(response.body, symbolize_names: true)
  end

  private

  def http_auth_key
    ActionController::HttpAuthentication::Basic.encode_credentials('test_goodnames', 'testtest')
  end
end
