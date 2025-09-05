require 'test_helper'

class ReppV1DomainsTransferTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"
    @domain = domains(:hospital)

    @auth_headers = { 'Authorization' => token }

    adapter = ENV["shunter_default_adapter"].constantize.new
    adapter&.clear!
  end

  def test_transfers_scoped_domain
    refute @domain.registrar == @user.registrar
    payload = { transfer: { transfer_code: @domain.transfer_code } }
    post "/repp/v1/domains/#{@domain.name}/transfer", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)
    @domain.reload

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    assert_equal @domain.registrar, @user.registrar
  end

  def test_does_not_transfer_scoped_domain_with_invalid_transfer_code
    refute @domain.registrar == @user.registrar
    payload = { transfer: { transfer_code: 'invalid' } }
    post "/repp/v1/domains/#{@domain.name}/transfer", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)
    @domain.reload

    assert_response :bad_request
    assert_equal 2202, json[:code]
    assert_equal 'Invalid authorization information', json[:message]

    refute @domain.registrar == @user.registrar
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

    assert_equal 'Object status prohibits operation', json[:data][:failed][0][:errors][:msg]

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

    assert_equal "Invalid authorization information", json[:data][:failed][0][:errors][:msg]
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

    assert_equal 'Domain already belongs to the querying registrar', json[:data][:failed][0][:errors][:msg]

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

    assert_equal 'Object is not eligible for transfer', json[:data][:failed][0][:errors][:msg]

    @domain.reload

    assert_not @domain.registrar == @user.registrar
  end

  def test_returns_error_response_if_throttled
    ENV["shunter_default_threshold"] = '1'
    ENV["shunter_enabled"] = 'true'

    payload = { transfer: { transfer_code: @domain.transfer_code } }
    post "/repp/v1/domains/#{@domain.name}/transfer", headers: @auth_headers, params: payload
    post "/repp/v1/domains/#{@domain.name}/transfer", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal json[:code], 2502
    assert response.body.include?(Shunter.default_error_message)
    ENV["shunter_default_threshold"] = '10000'
    ENV["shunter_enabled"] = 'false'
  end

  def test_transfers_domains_with_valid_csv
    csv_file = fixture_file_upload('files/domain_transfer_valid.csv', 'text/csv')
    
    post "/repp/v1/domains/transfer", headers: @auth_headers, params: { csv_file: csv_file }
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]
    assert_equal 1, json[:data][:success].length
    assert_equal @domain.name, json[:data][:success][0][:domain_name]
  end

  def test_returns_error_with_invalid_csv_headers
    csv_file = fixture_file_upload('files/domain_transfer_invalid.csv', 'text/csv')
    
    post "/repp/v1/domains/transfer", headers: @auth_headers, params: { csv_file: csv_file }
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 1, json[:data][:failed].length
    assert_equal 'csv_error', json[:data][:failed][0][:type]
    assert_includes json[:data][:failed][0][:message], 'CSV file is empty or missing required headers'
  end
end
