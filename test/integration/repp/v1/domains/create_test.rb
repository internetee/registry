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
        registrant_id: contact.code,
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
        registrant_id: contact.code,
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
        registrant_id: contact.code,
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
        registrant_id: contact.code,
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
end
