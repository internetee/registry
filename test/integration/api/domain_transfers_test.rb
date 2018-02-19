require 'test_helper'

class APIDomainTransfersTest < ActionDispatch::IntegrationTest
  def setup
    @domain = domains(:shop)
    Setting.transfer_wait_time = 0 # Auto-approval
  end

  def test_returns_domain_transfers
    post '/repp/v1/domain_transfers', request_params, { 'HTTP_AUTHORIZATION' => http_auth_key }
    assert_response 200
    assert_equal ({ data: [{
                             type: 'domain_transfer'
                           }] }),
                 JSON.parse(response.body, symbolize_names: true)
  end

  def test_creates_new_domain_transfer
    assert_difference -> { @domain.domain_transfers.size } do
      post '/repp/v1/domain_transfers', request_params, { 'HTTP_AUTHORIZATION' => http_auth_key }
    end
  end

  def test_approves_automatically_if_auto_approval_is_enabled
    post '/repp/v1/domain_transfers', request_params, { 'HTTP_AUTHORIZATION' => http_auth_key }
    assert @domain.domain_transfers(true).last.approved?
  end

  def test_changes_registrar
    post '/repp/v1/domain_transfers', request_params, { 'HTTP_AUTHORIZATION' => http_auth_key }
    @domain.reload
    assert_equal registrars(:goodnames), @domain.registrar
  end

  def test_regenerates_transfer_code
    @old_transfer_code = @domain.transfer_code

    post '/repp/v1/domain_transfers', request_params, { 'HTTP_AUTHORIZATION' => http_auth_key }
    @domain.reload
    refute_equal @domain.transfer_code, @old_transfer_code
  end

  def test_notifies_old_registrar
    @old_registrar = @domain.registrar

    assert_difference -> { @old_registrar.messages.count } do
      post '/repp/v1/domain_transfers', request_params, { 'HTTP_AUTHORIZATION' => http_auth_key }
    end

    message = 'Domain transfer of shop.test has been approved.' \
      ' Old contacts: jane-001, william-001' \
      '; old registrant: john-001'
    assert_equal message, @old_registrar.messages.last.body
  end

  def test_duplicates_registrant_admin_and_tech_contacts
    assert_difference 'Contact.count', 3 do
      post '/repp/v1/domain_transfers', request_params, { 'HTTP_AUTHORIZATION' => http_auth_key }
    end
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
    refute_equal registrars(:goodnames), @domain.registrar
    assert_equal ({ errors: [{ title: 'shop.test transfer code is wrong' }] }),
                 JSON.parse(response.body, symbolize_names: true)
  end

  private

  def request_params
    { format: :json,
      data: { domainTransfers: [{ domainName: 'shop.test', transferCode: '65078d5' }] } }
  end

  def http_auth_key
    ActionController::HttpAuthentication::Basic.encode_credentials('test_goodnames', 'testtest')
  end
end
