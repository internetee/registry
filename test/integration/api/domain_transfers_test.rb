require 'test_helper'

class APIDomainTransfersTest < ApplicationIntegrationTest
  setup do
    @domain = domains(:shop)
    @new_registrar = registrars(:goodnames)
    @original_transfer_wait_time = Setting.transfer_wait_time
    Setting.transfer_wait_time = 0 # Auto-approval
  end

  teardown do
    Setting.transfer_wait_time = @original_transfer_wait_time
  end

  def test_returns_domain_transfers
    post '/repp/v1/domain_transfers', params: request_params, as: :json,
         headers: { 'HTTP_AUTHORIZATION' => http_auth_key }
    assert_response 200
    assert_equal ({ data: [{
                             type: 'domain_transfer',
                             attributes: {
                               domain_name: 'shop.test'
                             },
                           }] }),
                 JSON.parse(response.body, symbolize_names: true)
  end

  def test_creates_new_domain_transfer
    assert_difference -> { @domain.transfers.size } do
      post '/repp/v1/domain_transfers', params: request_params, as: :json,
           headers: { 'HTTP_AUTHORIZATION' => http_auth_key }
    end
  end

  def test_approves_automatically_if_auto_approval_is_enabled
    post '/repp/v1/domain_transfers', params: request_params, as: :json,
         headers: { 'HTTP_AUTHORIZATION' => http_auth_key }
    assert @domain.transfers.last.approved?
  end

  def test_assigns_new_registrar
    post '/repp/v1/domain_transfers', params: request_params, as: :json,
         headers: { 'HTTP_AUTHORIZATION' => http_auth_key }
    @domain.reload
    assert_equal @new_registrar, @domain.registrar
  end

  def test_regenerates_transfer_code
    @old_transfer_code = @domain.transfer_code

    post '/repp/v1/domain_transfers', params: request_params, as: :json,
         headers: { 'HTTP_AUTHORIZATION' => http_auth_key }
    @domain.reload
    refute_equal @domain.transfer_code, @old_transfer_code
  end

  def test_notifies_old_registrar
    @old_registrar = @domain.registrar

    assert_difference -> { @old_registrar.notifications.count } do
      post '/repp/v1/domain_transfers', params: request_params, as: :json,
           headers: { 'HTTP_AUTHORIZATION' => http_auth_key }
    end
  end

  def test_duplicates_registrant_admin_and_tech_contacts
    assert_difference -> { @new_registrar.contacts.size }, 3 do
      post '/repp/v1/domain_transfers', params: request_params, as: :json,
           headers: { 'HTTP_AUTHORIZATION' => http_auth_key }
    end
  end

  def test_reuses_identical_contact
    post '/repp/v1/domain_transfers', params: request_params, as: :json,
         headers: { 'HTTP_AUTHORIZATION' => http_auth_key }
    assert_equal 1, @new_registrar.contacts.where(name: 'William').size
  end

  def test_fails_if_domain_does_not_exist
    post '/repp/v1/domain_transfers',
         params: { data: { domainTransfers: [{ domainName: 'non-existent.test',
                                               transferCode: 'any' }] } },
         as: :json,
         headers: { 'HTTP_AUTHORIZATION' => http_auth_key }
    assert_response 400
    assert_equal ({ errors: [{ title: 'non-existent.test does not exist' }] }),
                 JSON.parse(response.body, symbolize_names: true)
  end

  def test_fails_if_transfer_code_is_wrong
    post '/repp/v1/domain_transfers',
         params: { data: { domainTransfers: [{ domainName: 'shop.test',
                                               transferCode: 'wrong' }] } },
         as: :json,
         headers: { 'HTTP_AUTHORIZATION' => http_auth_key }
    assert_response 400
    refute_equal @new_registrar, @domain.registrar
    assert_equal ({ errors: [{ title: 'shop.test transfer code is wrong' }] }),
                 JSON.parse(response.body, symbolize_names: true)
  end

  private

  def request_params
    { data: { domainTransfers: [{ domainName: 'shop.test', transferCode: '65078d5' }] } }
  end

  def http_auth_key
    ActionController::HttpAuthentication::Basic.encode_credentials('test_goodnames', 'testtest')
  end
end
