require 'test_helper'
require 'auth_token/auth_token_creator'

CompanyRegisterClientStub = Struct.new(:any_method) do
  def representation_rights(citizen_personal_code:, citizen_country_code:)
    raise CompanyRegister::NotAvailableError
  end
end

class RegistrantApiV1ContactDetailsTest < ActionDispatch::IntegrationTest
  setup do
    @contact = contacts(:john)
    @user = users(:registrant)
  end

  def test_returns_direct_contact_when_company_register_is_unavailable
    assert_equal '1234', @contact.ident
    assert_equal Contact::PRIV, @contact.ident_type
    assert_equal 'US', @contact.ident_country_code
    assert_equal 'US-1234', @user.registrant_ident

    CompanyRegister::Client.stub(:new, CompanyRegisterClientStub.new) do
      get api_v1_registrant_contact_path(@contact.uuid), nil, 'HTTP_AUTHORIZATION' => auth_token,
          'Content-Type' => Mime::JSON.to_s
    end

    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal '1234', response_json[:ident]
  end

  def test_unmanaged_contact_cannot_be_accessed
    assert_equal 'US-1234', @user.registrant_ident
    @contact.update!(ident: '12345')

    get api_v1_registrant_contact_path(@contact.uuid), nil, 'HTTP_AUTHORIZATION' => auth_token,
        'Content-Type' => Mime::JSON.to_s

    assert_response :not_found
    response_json = JSON.parse(response.body, symbolize_names: true)
    assert_equal ({ errors: [base: ['Contact not found']] }), response_json
  end

  private

  def auth_token
    token_creator = AuthTokenCreator.create_with_defaults(@user)
    hash = token_creator.token_in_hash
    "Bearer #{hash[:access_token]}"
  end
end