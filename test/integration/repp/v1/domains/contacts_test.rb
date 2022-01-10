require 'test_helper'

class ReppV1DomainsContactsTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    @domain = domains(:shop)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_shows_existing_domain_contacts
    get "/repp/v1/domains/#{@domain.name}/contacts", headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_equal 'Command completed successfully', json[:message]

    assert_equal @domain.admin_contacts.length, json[:data][:admin_contacts].length
    assert_equal @domain.tech_contacts.length, json[:data][:tech_contacts].length
  end

  def test_can_add_new_admin_contacts
    new_contact = contacts(:john)
    refute  @domain.admin_contacts.find_by(code: new_contact.code).present?

    payload = { contacts: [ { code: new_contact.code, type: 'admin' } ] }
    post "/repp/v1/domains/#{@domain.name}/contacts", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]

    assert @domain.admin_contacts.find_by(code: new_contact.code).present?
  end

  def test_can_add_new_tech_contacts
    new_contact = contacts(:john)
    refute  @domain.tech_contacts.find_by(code: new_contact.code).present?

    payload = { contacts: [ { code: new_contact.code, type: 'tech' } ] }
    post "/repp/v1/domains/#{@domain.name}/contacts", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    @domain.reload

    assert @domain.tech_contacts.find_by(code: new_contact.code).present?
  end

  def test_can_remove_admin_contacts
    contact = contacts(:john)
    payload = { contacts: [ { code: contact.code, type: 'admin' } ] }
    post "/repp/v1/domains/#{@domain.name}/contacts", headers: @auth_headers, params: payload
    assert @domain.admin_contacts.find_by(code: contact.code).present?

    # Actually delete the contact
    delete "/repp/v1/domains/#{@domain.name}/contacts", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]

    refute @domain.admin_contacts.find_by(code: contact.code).present?
  end

  def test_can_remove_tech_contacts
    contact = contacts(:john)
    payload = { contacts: [ { code: contact.code, type: 'tech' } ] }
    post "/repp/v1/domains/#{@domain.name}/contacts", headers: @auth_headers, params: payload
    assert @domain.tech_contacts.find_by(code: contact.code).present?

    # Actually delete the contact
    delete "/repp/v1/domains/#{@domain.name}/contacts", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]

    refute @domain.tech_contacts.find_by(code: contact.code).present?
  end

  def test_can_not_remove_one_and_only_contact
    contact = @domain.admin_contacts.last

    payload = { contacts: [ { code: contact.code, type: 'admin' } ] }
    delete "/repp/v1/domains/#{@domain.name}/contacts", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)

    @domain.reload
    assert_response :bad_request
    assert_equal 2004, json[:code]

    assert @domain.admin_contacts.any?
  end

end
