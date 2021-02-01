require 'test_helper'

class ReppV1ContactsTechReplaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_replaces_tech_contacts
    old_contact = contacts(:john)
    new_contact = contacts(:william)

    assert DomainContact.where(contact: old_contact, type: 'TechDomainContact').any?

    payload = { current_contact_id: old_contact.code, new_contact_id: new_contact.code}
    patch "/repp/v1/domains/contacts", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok
    assert_equal 1000, json[:code]
    assert_empty ["hospital.test", "library.test"] - json[:data][:affected_domains]

    assert DomainContact.where(contact: old_contact, type: 'TechDomainContact').blank?
  end

  def test_validates_contact_codes
    payload = { current_contact_id: 'aaa', new_contact_id: 'bbb'}
    patch "/repp/v1/domains/contacts", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :not_found
    assert_equal 2303, json[:code]
    assert_equal 'Object does not exist', json[:message]
  end

  def test_new_contact_must_be_different
    old_contact = contacts(:john)

    payload = { current_contact_id: old_contact.code, new_contact_id: old_contact.code }
    patch "/repp/v1/domains/contacts", headers: @auth_headers, params: payload
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :bad_request
    assert_equal 2304, json[:code]
    assert_equal 'New contact must be different from current', json[:message]
  end
end
