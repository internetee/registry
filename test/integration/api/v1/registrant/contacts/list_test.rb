require 'test_helper'
require 'auth_token/auth_token_creator'
require 'json'

CompanyRegisterClientStub = Struct.new(:any_method) do
  def representation_rights(citizen_personal_code:, citizen_country_code:)
    raise CompanyRegister::NotAvailableError
  end
end

class RegistrantApiV1ContactListTest < ActionDispatch::IntegrationTest
  setup do
    @contact = contacts(:john)
    @user = users(:registrant)
  end

  def test_returns_direct_contacts
    delete_indirect_contact
    assert_equal '1234', @contact.ident
    assert_equal Contact::PRIV, @contact.ident_type
    assert_equal 'US', @contact.ident_country_code
    assert_equal 'US-1234', @user.registrant_ident

    get api_v1_registrant_contacts_path, as: :json, headers: { 'HTTP_AUTHORIZATION' => auth_token }

    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal 1, response_json.size
    assert_equal '1234', response_json.first[:ident][:code]
  end

  def test_returns_indirect_contacts
    delete_direct_contact
    @contact = contacts(:acme_ltd)
    assert_equal 'acme-ltd-001', @contact.code

    get api_v1_registrant_contacts_path, as: :json, headers: { 'HTTP_AUTHORIZATION' => auth_token }

    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal @user.contacts(representable: false).count, response_json.size
    assert_includes response_json.map{ |hash| hash[:code] }, @contact.code
  end

  def test_returns_direct_contacts_when_company_register_is_unavailable
    assert_equal '1234', @contact.ident
    assert_equal Contact::PRIV, @contact.ident_type
    assert_equal 'US', @contact.ident_country_code
    assert_equal 'US-1234', @user.registrant_ident

    CompanyRegister::Client.stub(:new, CompanyRegisterClientStub.new) do
      get api_v1_registrant_contacts_path, as: :json,
          headers: { 'HTTP_AUTHORIZATION' => auth_token }
    end

    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal 1, response_json.size
    assert_equal '1234', response_json.first[:ident][:code]
  end

  def test_out_of_range_limit
    get api_v1_registrant_contacts_path + "?limit=300", as: :json, headers: { 'HTTP_AUTHORIZATION' => auth_token }
    response_json = JSON.parse(response.body, symbolize_names: true)

    text_response = JSON.pretty_generate(response_json[:errors][0][:limit][0])

    assert_equal text_response, '"parameter is out of range"'
  end

  def test_negative_offset
    get api_v1_registrant_contacts_path + "?offset=-300", as: :json, headers: { 'HTTP_AUTHORIZATION' => auth_token }
    response_json = JSON.parse(response.body, symbolize_names: true)

    text_response = JSON.pretty_generate(response_json[:errors][0][:offset][0])

    assert_equal text_response, '"parameter is out of range"'
  end

  def test_show_valid_contact
    get api_v1_registrant_contacts_path + "/eb2f2766-b44c-4e14-9f16-32ab1a7cb957", as: :json, headers: { 'HTTP_AUTHORIZATION' => auth_token }
    response_json = JSON.parse(response.body, symbolize_names: true)

    text_response = response_json[:name]

    assert_equal @contact[:name], text_response
  end

  def test_show_invalid_contact
    get api_v1_registrant_contacts_path + "/435", as: :json, headers: { 'HTTP_AUTHORIZATION' => auth_token }
    response_json = JSON.parse(response.body, symbolize_names: true)

    text_response = response_json[:errors][0][:base][0]

    assert_equal text_response, 'Contact not found'
  end

  private

  def delete_direct_contact
    ActiveRecord::Base.connection.disable_referential_integrity { contacts(:john).delete }
  end

  def delete_indirect_contact
    ActiveRecord::Base.connection.disable_referential_integrity { contacts(:acme_ltd).delete }
  end

  def auth_token
    token_creator = AuthTokenCreator.create_with_defaults(@user)
    hash = token_creator.token_in_hash
    "Bearer #{hash[:access_token]}"
  end
end
