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

  def test_transfers_domain_with_valid_dns_records
    # Add nameservers to the domain
    @domain.nameservers.create!(hostname: 'ns1.example.com', ipv4: ['192.0.2.1'])
    @domain.nameservers.create!(hostname: 'ns2.example.com', ipv4: ['192.0.2.2'])

    # Mock successful DNS validation for NS records
    DNSValidator.stub :validate, { errors: [] } do
      payload = { transfer: { transfer_code: @domain.transfer_code } }
      post "/repp/v1/domains/#{@domain.name}/transfer", headers: @auth_headers, params: payload
      json = JSON.parse(response.body, symbolize_names: true)
      @domain.reload

      assert_response :ok
      assert_equal 1000, json[:code]
      assert_equal 'Command completed successfully', json[:message]
      assert_equal @domain.registrar, @user.registrar
    end
  end

  def test_fails_transfer_with_invalid_nameserver_records
    # Add nameservers to the domain
    @domain.nameservers.create!(hostname: 'ns1.example.com', ipv4: ['192.0.2.1'])
    @domain.nameservers.create!(hostname: 'ns2.example.com', ipv4: ['192.0.2.2'])

    # Mock DNS validation failure for NS records
    dns_error = 'Nameserver ns1.example.com is not authoritative for domain'
    DNSValidator.stub :validate, { errors: [dns_error] } do
      payload = { transfer: { transfer_code: @domain.transfer_code } }
      post "/repp/v1/domains/#{@domain.name}/transfer", headers: @auth_headers, params: payload
      json = JSON.parse(response.body, symbolize_names: true)
      @domain.reload

      assert_response :bad_request
      assert_equal 2306, json[:code]
      assert_equal dns_error, json[:message]
      
      # Domain should not be transferred
      refute @domain.registrar == @user.registrar
    end
  end

  def test_transfers_domain_with_valid_dnssec_records
    # Add DNSSEC keys to the domain
    @domain.dnskeys.create!(
      flags: 257,
      protocol: 3,
      alg: 8,
      public_key: 'AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCRHzfK'
    )

    # Mock successful DNS validation for DNSKEY records
    DNSValidator.stub :validate, { errors: [] } do
      payload = { transfer: { transfer_code: @domain.transfer_code } }
      post "/repp/v1/domains/#{@domain.name}/transfer", headers: @auth_headers, params: payload
      json = JSON.parse(response.body, symbolize_names: true)
      @domain.reload

      assert_response :ok
      assert_equal 1000, json[:code]
      assert_equal 'Command completed successfully', json[:message]
      assert_equal @domain.registrar, @user.registrar
    end
  end

  def test_fails_transfer_with_invalid_dnssec_records
    # Add DNSSEC keys to the domain
    @domain.dnskeys.create!(
      flags: 257,
      protocol: 3,
      alg: 8,
      public_key: 'AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCRHzfK'
    )

    # Mock DNS validation failure for DNSKEY records
    dns_error = 'DNSKEY record not found in DNS'
    DNSValidator.stub :validate, { errors: [dns_error] } do
      payload = { transfer: { transfer_code: @domain.transfer_code } }
      post "/repp/v1/domains/#{@domain.name}/transfer", headers: @auth_headers, params: payload
      json = JSON.parse(response.body, symbolize_names: true)
      @domain.reload

      assert_response :bad_request
      assert_equal 2306, json[:code]
      assert_equal dns_error, json[:message]
      
      # Domain should not be transferred
      refute @domain.registrar == @user.registrar
    end
  end

  def test_transfers_domain_without_nameservers
    # Ensure domain has no nameservers
    @domain.nameservers.destroy_all

    # Should transfer successfully without DNS validation
    payload = { transfer: { transfer_code: @domain.transfer_code } }
    post "/repp/v1/domains/#{@domain.name}/transfer", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)
    @domain.reload

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]
    assert_equal @domain.registrar, @user.registrar
  end

  def test_transfers_domain_without_dnssec
    # Ensure domain has no DNSSEC keys
    @domain.dnskeys.destroy_all

    # Should transfer successfully without DNSSEC validation
    payload = { transfer: { transfer_code: @domain.transfer_code } }
    post "/repp/v1/domains/#{@domain.name}/transfer", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)
    @domain.reload

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]
    assert_equal @domain.registrar, @user.registrar
  end

  def test_bulk_transfer_with_dns_validation
    domain2 = domains(:metro)
    
    # Add minimum required nameservers to both domains (2 nameservers required)
    @domain.nameservers.create!(hostname: 'ns1.example.com', ipv4: ['192.0.2.1'])
    @domain.nameservers.create!(hostname: 'ns2.example.com', ipv4: ['192.0.2.2'])
    
    domain2.nameservers.create!(hostname: 'ns1.example.org', ipv4: ['192.0.2.10'])
    domain2.nameservers.create!(hostname: 'ns2.example.org', ipv4: ['192.0.2.11'])
    
    # Mock DNS validation - success for both domains
    DNSValidator.stub :validate, { errors: [] } do
      payload = {
        "data": {
          "domain_transfers": [
            { "domain_name": @domain.name, "transfer_code": @domain.transfer_code },
            { "domain_name": domain2.name, "transfer_code": domain2.transfer_code }
          ]
        }
      }
      
      post "/repp/v1/domains/transfer", headers: @auth_headers, params: payload
      json = JSON.parse(response.body, symbolize_names: true)

      assert_response :ok
      assert_equal 1000, json[:code]
      assert_equal 'Command completed successfully', json[:message]
      
      # Both domains should be in success list
      assert_equal 2, json[:data][:success].length
      assert json[:data][:success].any? { |d| d[:domain_name] == @domain.name }
      assert json[:data][:success].any? { |d| d[:domain_name] == domain2.name }
      
      @domain.reload
      domain2.reload
      
      assert @domain.registrar == @user.registrar
      assert domain2.registrar == @user.registrar
    end
  end

  def test_bulk_transfer_with_mixed_dns_validation_results
    domain2 = domains(:metro)
    
    # Add minimum required nameservers to both domains (2 nameservers required)
    @domain.nameservers.create!(hostname: 'ns1.example.com', ipv4: ['192.0.2.1'])
    @domain.nameservers.create!(hostname: 'ns2.example.com', ipv4: ['192.0.2.2'])
    
    domain2.nameservers.create!(hostname: 'ns1.example.org', ipv4: ['192.0.2.10'])
    domain2.nameservers.create!(hostname: 'ns2.example.org', ipv4: ['192.0.2.11'])
    
    # Mock DNS validation - fail for first domain, succeed for second
    validation_results = {
      @domain.name => { errors: ['Nameserver ns1.example.com is not authoritative'] },
      domain2.name => { errors: [] }
    }
    
    DNSValidator.stub :validate, ->(domain:, **) { 
      validation_results[domain.name] || { errors: [] }
    } do
      payload = {
        "data": {
          "domain_transfers": [
            { "domain_name": @domain.name, "transfer_code": @domain.transfer_code },
            { "domain_name": domain2.name, "transfer_code": domain2.transfer_code }
          ]
        }
      }
      
      post "/repp/v1/domains/transfer", headers: @auth_headers, params: payload
      json = JSON.parse(response.body, symbolize_names: true)

      assert_response :ok
      assert_equal 1000, json[:code]
      
      # First domain should fail, second should succeed
      assert_equal 1, json[:data][:success].length
      assert_equal domain2.name, json[:data][:success][0][:domain_name]
      
      assert_equal 1, json[:data][:failed].length
      assert_equal @domain.name, json[:data][:failed][0][:domain_name]
      assert json[:data][:failed][0][:errors][:msg].include?('not authoritative')
      
      @domain.reload
      domain2.reload
      
      # Only domain2 should be transferred
      refute @domain.registrar == @user.registrar
      assert domain2.registrar == @user.registrar
    end
  end
end
