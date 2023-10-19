require 'test_helper'

class ReppV1DomainsCreateTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    @domain = domains(:shop)
    @bsa_domain = bsa_protected_domains(:one)
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

  def test_domain_cannnot_be_created_if_it_in_bsa_protected_list
    @auth_headers['Content-Type'] = 'application/json'
    contact = contacts(:john)

    payload = {
      domain: {
        name: @bsa_domain.domain_name,
        registrant: contact.code,
        period: 1,
        period_unit: 'y'
      }
    }

    post "/repp/v1/domains", headers: @auth_headers, params: payload.to_json
    json = JSON.parse(response.body, symbolize_names: true)
    assert_response :bad_request
    assert_equal 2003, json[:code]
    assert_equal 'Required parameter missing; reserved>pw element required for reserved domains', json[:message]

    refute @user.registrar.domains.find_by(name: @bsa_domain.domain_name).present?
  end

  def test_bsa_protected_domain_can_be_created_with_valid_registration_code
    @auth_headers['Content-Type'] = 'application/json'
    contact = contacts(:john)

    payload = {
      domain: {
        name: @bsa_domain.domain_name,
        registrant: contact.code,
        reserved_pw: @bsa_domain.registration_code,
        period: 1,
        period_unit: 'y'
      }
    }

    post "/repp/v1/domains", headers: @auth_headers, params: payload.to_json
    json = JSON.parse(response.body, symbolize_names: true)
    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    assert @user.registrar.domains.find_by(name: @bsa_domain.domain_name).present?
  end

  def test_bsa_protected_domain_cannot_be_created_with_invalid_registration_code
    @auth_headers['Content-Type'] = 'application/json'
    contact = contacts(:john)

    payload = {
      domain: {
        name: @bsa_domain.domain_name,
        registrant: contact.code,
        reserved_pw: 'invalid_registration_code',
        period: 1,
        period_unit: 'y'
      }
    }

    post "/repp/v1/domains", headers: @auth_headers, params: payload.to_json
    json = JSON.parse(response.body, symbolize_names: true)
    assert_response :bad_request
    assert_equal 2202, json[:code]
    assert_equal 'Invalid authorization information; invalid reserved>pw value', json[:message]

    refute @user.registrar.domains.find_by(name: @bsa_domain.domain_name).present?
  end
end
