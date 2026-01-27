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

  def test_creates_new_domain_transfer
    assert_difference -> { @domain.transfers.size } do
      post '/repp/v1/domains/transfer', params: request_params, as: :json,
           headers: { 'HTTP_AUTHORIZATION' => http_auth_key }
    end
  end

  def test_approves_automatically_if_auto_approval_is_enabled
    post '/repp/v1/domains/transfer', params: request_params, as: :json,
         headers: { 'HTTP_AUTHORIZATION' => http_auth_key }
    assert @domain.transfers.last.approved?
  end

  def test_assigns_new_registrar
    post '/repp/v1/domains/transfer', params: request_params, as: :json,
         headers: { 'HTTP_AUTHORIZATION' => http_auth_key }
    @domain.reload
    assert_equal @new_registrar, @domain.registrar
  end

  def test_regenerates_transfer_code
    @old_transfer_code = @domain.transfer_code

    post '/repp/v1/domains/transfer', params: request_params, as: :json,
         headers: { 'HTTP_AUTHORIZATION' => http_auth_key }
    @domain.reload
    refute_equal @domain.transfer_code, @old_transfer_code
  end

  def test_notifies_old_registrar
    @old_registrar = @domain.registrar

    assert_difference -> { @old_registrar.notifications.count } do
      post '/repp/v1/domains/transfer', params: request_params, as: :json,
           headers: { 'HTTP_AUTHORIZATION' => http_auth_key }
    end
  end

  def test_duplicates_registrant_admin_and_tech_contacts
    assert_difference -> { @new_registrar.contacts.size }, 3 do
      post '/repp/v1/domains/transfer', params: request_params, as: :json,
           headers: { 'HTTP_AUTHORIZATION' => http_auth_key }
    end
  end

  def test_reuses_identical_contact
    post '/repp/v1/domains/transfer', params: request_params, as: :json,
         headers: { 'HTTP_AUTHORIZATION' => http_auth_key }
    assert_equal 1, @new_registrar.contacts.where(name: 'William').size
  end

  def test_bulk_transfer_if_domain_has_update_prohibited_status
    domains(:shop).update!(statuses: [DomainStatus::SERVER_UPDATE_PROHIBITED])

    post '/repp/v1/domains/transfer', params: request_params, as: :json,
         headers: { 'HTTP_AUTHORIZATION' => http_auth_key }

    assert_response :bad_request
    json = JSON.parse(response.body, symbolize_names: true)
    
    assert_equal 2304, json[:code]
    assert_equal 'All 1 transfers failed: 1 domain prohibited from transfer', json[:message]
    assert_equal [], json[:data][:success]
    assert_equal 1, json[:data][:failed].size
    
    failed_transfer = json[:data][:failed][0]
    assert_equal 'domain_transfer', failed_transfer[:type]
    assert_equal 'shop.test', failed_transfer[:domain_name]
    assert_equal '2304', failed_transfer[:error_code]
    assert_equal 'Object status prohibits operation', failed_transfer[:error_message]
  end

  private

  def request_params
    { data: { domain_transfers: [{ domain_name: 'shop.test', transfer_code: '65078d5' }] } }
  end

  def http_auth_key
    ActionController::HttpAuthentication::Basic.encode_credentials('test_goodnames', 'testtest')
  end
end
