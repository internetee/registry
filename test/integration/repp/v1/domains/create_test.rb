require 'test_helper'

class ReppV1DomainsCreateTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    @domain = domains(:shop)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_creates_new_domain_successfully
    @auth_headers['Content-Type'] = 'application/json'
    contact = contacts(:john)

    payload = {
      domain: {
        name: 'domeener.test',
        registrant: contact.code,
        period: 1,
        period_unit: 'y'
      }
    }

    post "/repp/v1/domains", headers: @auth_headers, params: payload.to_json
    json = JSON.parse(response.body, symbolize_names: true)
    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    assert @user.registrar.domains.find_by(name: 'domeener.test').present?
  end

  def test_validates_price_on_domain_create
    @auth_headers['Content-Type'] = 'application/json'
    contact = contacts(:john)

    payload = {
      domain: {
        name: 'domeener.test',
        registrant: contact.code,
        period: 3,
        period_unit: 'y'
      }
    }

    post "/repp/v1/domains", headers: @auth_headers, params: payload.to_json
    json = JSON.parse(response.body, symbolize_names: true)
    assert_response :bad_request
    assert_equal 2104, json[:code]
    assert_equal 'Active price missing for this operation!', json[:message]

    refute @user.registrar.domains.find_by(name: 'domeener.test').present?
  end

  def test_creates_domain_with_predefined_nameservers
    @auth_headers['Content-Type'] = 'application/json'
    contact = contacts(:john)

    payload = {
      domain: {
        name: 'domeener.test',
        registrant: contact.code,
        period: 1,
        period_unit: 'y',
        nameservers_attributes: [
          { hostname: 'ns1.domeener.ee' },
          { hostname: 'ns2.domeener.ee' }
        ]
      }
    }

    post "/repp/v1/domains", headers: @auth_headers, params: payload.to_json
    json = JSON.parse(response.body, symbolize_names: true)
    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    domain = @user.registrar.domains.find_by(name: 'domeener.test')
    assert domain.present?
    assert_empty ['ns1.domeener.ee', 'ns2.domeener.ee'] - domain.nameservers.collect(&:hostname)
  end

  def test_creates_domain_with_custom_contacts
    @auth_headers['Content-Type'] = 'application/json'
    contact = contacts(:john)
    admin_contact = contacts(:william)
    tech_contact = contacts(:jane)

    payload = {
      domain: {
        name: 'domeener.test',
        registrant: contact.code,
        period: 1,
        period_unit: 'y',
        admin_contacts: [ admin_contact.code ],
        tech_contacts: [ tech_contact.code ],
      }
    }

    post "/repp/v1/domains", headers: @auth_headers, params: payload.to_json
    json = JSON.parse(response.body, symbolize_names: true)
    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    domain = @user.registrar.domains.find_by(name: 'domeener.test')
    assert domain.present?
    assert_equal tech_contact, domain.tech_domain_contacts.first.contact
    assert_equal admin_contact, domain.admin_domain_contacts.first.contact
  end

  def test_creates_new_domain_with_desired_transfer_code
    @auth_headers['Content-Type'] = 'application/json'
    contact = contacts(:john)

    payload = {
      domain: {
        name: 'domeener.test',
        registrant: contact.code,
        transfer_code: 'ABADIATS',
        period: 1,
        period_unit: 'y'
      }
    }

    post "/repp/v1/domains", headers: @auth_headers, params: payload.to_json
    json = JSON.parse(response.body, symbolize_names: true)
    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    assert @user.registrar.domains.find_by(name: 'domeener.test').present?
    assert_equal 'ABADIATS', @user.registrar.domains.find_by(name: 'domeener.test').transfer_code
  end

  def test_creates_domain_with_nameservers_validates_dns
    ENV['DNS_VALIDATION_ENABLED'] = 'true'
    
    @auth_headers['Content-Type'] = 'application/json'
    contact = contacts(:john)

    # Mock successful DNS validation
    DNSValidator.stub :validate, { errors: [] } do
      payload = {
      domain: {
        name: 'domeener.test',
        registrant: contact.code,
        period: 1,
        period_unit: 'y',
        nameservers_attributes: [
          { hostname: 'ns1.example.com' },
          { hostname: 'ns2.example.com' }
        ]
      }
    }

    post "/repp/v1/domains", headers: @auth_headers, params: payload.to_json
    json = JSON.parse(response.body, symbolize_names: true)
    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

      domain = @user.registrar.domains.find_by(name: 'domeener.test')
      assert domain.present?
      assert_equal 2, domain.nameservers.count
    end
  ensure
    ENV.delete('DNS_VALIDATION_ENABLED')
  end

  def test_fails_to_create_domain_with_invalid_nameservers
    ENV['DNS_VALIDATION_ENABLED'] = 'true'
    
    @auth_headers['Content-Type'] = 'application/json'
    contact = contacts(:john)

    # Mock DNS validation failure
    DNSValidator.stub :validate, { errors: ['Nameserver ns1.example.com is not authoritative for domain'] } do
      payload = {
        domain: {
          name: 'domeener.test',
          registrant: contact.code,
          period: 1,
          period_unit: 'y',
          nameservers_attributes: [
            { hostname: 'ns1.example.com' },
            { hostname: 'ns2.example.com' }
          ]
        }
      }

      post "/repp/v1/domains", headers: @auth_headers, params: payload.to_json
      json = JSON.parse(response.body, symbolize_names: true)
      assert_response :bad_request
      assert_equal 2306, json[:code]
      assert json[:message].include?('Nameserver ns1.example.com is not authoritative')

      refute @user.registrar.domains.find_by(name: 'domeener.test').present?
    end
  ensure
    ENV.delete('DNS_VALIDATION_ENABLED')
  end

  def test_creates_domain_with_dnssec_validates_dnskey
    ENV['DNS_VALIDATION_ENABLED'] = 'true'
    
    @auth_headers['Content-Type'] = 'application/json'
    contact = contacts(:john)

    # Mock successful DNSSEC validation
    DNSValidator.stub :validate, { errors: [] } do
      payload = {
        domain: {
          name: 'domeener.test',
          registrant: contact.code,
          period: 1,
          period_unit: 'y',
          dnskeys_attributes: [
            {
              flags: '257',
              protocol: '3',
              alg: '8',
              public_key: 'AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8'
            }
          ]
        }
      }

      post "/repp/v1/domains", headers: @auth_headers, params: payload.to_json
      json = JSON.parse(response.body, symbolize_names: true)
      assert_response :ok
      assert_equal 1000, json[:code]
      assert_equal 'Command completed successfully', json[:message]

      domain = @user.registrar.domains.find_by(name: 'domeener.test')
      assert domain.present?
      assert_equal 1, domain.dnskeys.count
    end
  ensure
    ENV.delete('DNS_VALIDATION_ENABLED')
  end

  def test_fails_to_create_domain_with_invalid_dnskey
    ENV['DNS_VALIDATION_ENABLED'] = 'true'
    
    @auth_headers['Content-Type'] = 'application/json'
    contact = contacts(:john)

    # Mock DNSSEC validation failure
    DNSValidator.stub :validate, { errors: ['DNSKEY record not found in DNS'] } do
      payload = {
        domain: {
          name: 'domeener.test',
          registrant: contact.code,
          period: 1,
          period_unit: 'y',
          dnskeys_attributes: [
            {
              flags: '257',
              protocol: '3',
              alg: '8',
              public_key: 'AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8'
            }
          ]
        }
      }

      post "/repp/v1/domains", headers: @auth_headers, params: payload.to_json
      json = JSON.parse(response.body, symbolize_names: true)
      assert_response :bad_request
      assert_equal 2306, json[:code]
      assert json[:message].include?('DNSKEY record not found')

      refute @user.registrar.domains.find_by(name: 'domeener.test').present?
    end
  ensure
    ENV.delete('DNS_VALIDATION_ENABLED')
  end
end
