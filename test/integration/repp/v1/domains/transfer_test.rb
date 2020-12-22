require 'test_helper'

class ReppV1DomainsTransferTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"
    @domain = domains(:hospital)

    @auth_headers = { 'Authorization' => token }
  end

  def test_transfers_domain
    payload = {
      "data": {
        "domain_transfers": [
          { "domain_name": @domain.name, "transfer_code": @domain.transfer_code }
        ]
      }
    }
    post "/repp/v1/domains/transfer", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    assert_equal @domain.name, json[:data][:success][0][:domain_name]

    @domain.reload

    assert @domain.registrar = @user.registrar
  end

  def test_does_not_transfer_domain_if_not_transferable
    @domain.schedule_force_delete(type: :fast_track)

    payload = {
      "data": {
        "domain_transfers": [
          { "domain_name": @domain.name, "transfer_code": @domain.transfer_code }
        ]
      }
    }

    post "/repp/v1/domains/transfer", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    assert_equal 'Object status prohibits operation', json[:data][:failed][0][:errors][0][:msg]

    @domain.reload

    assert_not @domain.registrar == @user.registrar
  end

  def test_does_not_transfer_domain_with_invalid_auth_code
    payload = {
      "data": {
        "domain_transfers": [
          { "domain_name": @domain.name, "transfer_code": "sdfgsdfg" }
        ]
      }
    }
    post "/repp/v1/domains/transfer", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    assert_equal "Invalid authorization information", json[:data][:failed][0][:errors][0][:msg]
  end

  def test_does_not_transfer_domain_to_same_registrar
    @domain.update!(registrar: @user.registrar)

    payload = {
      "data": {
        "domain_transfers": [
          { "domain_name": @domain.name, "transfer_code": @domain.transfer_code }
        ]
      }
    }

    post "/repp/v1/domains/transfer", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    assert_equal 'Domain already belongs to the querying registrar', json[:data][:failed][0][:errors][0][:msg]

    @domain.reload

    assert @domain.registrar == @user.registrar
  end

  def test_does_not_transfer_domain_if_discarded
    @domain.update!(statuses: [DomainStatus::DELETE_CANDIDATE])

    payload = {
      "data": {
        "domain_transfers": [
          { "domain_name": @domain.name, "transfer_code": @domain.transfer_code }
        ]
      }
    }

    post "/repp/v1/domains/transfer", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    assert_equal 'Object is not eligible for transfer', json[:data][:failed][0][:errors][0][:msg]

    @domain.reload

    assert_not @domain.registrar == @user.registrar
  end
end
