require 'test_helper'

class APIDomainTransfersTest < ApplicationIntegrationTest
  setup do
    @domain = domains(:shop)
    @new_registrar = registrars(:goodnames)
    @original_transfer_wait_time = Setting.transfer_wait_time
    Setting.transfer_wait_time = 0 # Auto-approval
    
    # Mock DNSValidator to return success
    @original_validate = DNSValidator.method(:validate)
    DNSValidator.define_singleton_method(:validate) { |**args| { errors: [] } }
  end

  teardown do
    Setting.transfer_wait_time = @original_transfer_wait_time
    # Restore original validate method
    DNSValidator.define_singleton_method(:validate, @original_validate)
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

    assert_response :ok
    assert_equal ({ code: 1000,
                    message: 'Command completed successfully',
                    data: { success: [],
                    failed: [{ type: "domain_transfer",
                               domain_name: "shop.test",
                               errors: {:code=>"2304", :msg=>"Object status prohibits operation"} }],
                    }}),
                JSON.parse(response.body, symbolize_names: true)
  end

  private

  def request_params
    { data: { domain_transfers: [{ domain_name: 'shop.test', transfer_code: '65078d5' }] } }
  end

  def http_auth_key
    ActionController::HttpAuthentication::Basic.encode_credentials('test_goodnames', 'testtest')
  end
end
