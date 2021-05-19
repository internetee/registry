require 'test_helper'
require 'auth_token/auth_token_creator'

CompanyRegisterClientStub = Struct.new(:any_method) do
  def representation_rights(citizen_personal_code:, citizen_country_code:)
    raise CompanyRegister::NotAvailableError
  end
end

class RegistrantApiV1DomainsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:registrant)
    @registrar = registrars(:bestnames)
    @contact = contacts(:john)
  end

  def test_get_default_counts_of_domains
    get api_v1_registrant_domains_path + "?tech=init", as: :json,
    headers: { 'HTTP_AUTHORIZATION' => auth_token }

    assert_response :ok

    response_json = JSON.parse(response.body)
    assert_equal response_json['total'], 4
    assert_equal response_json['count'], 4
  end

  def test_get_default_counts_of_direct_domains
    CompanyRegister::Client.stub(:new, CompanyRegisterClientStub.new) do
      get api_v1_registrant_domains_path + "?tech=init", as: :json,
          headers: { 'HTTP_AUTHORIZATION' => auth_token }
    end

    response_json = JSON.parse(response.body)
    assert_equal response_json['total'], 4
    assert_equal response_json['count'], 4
  end

  private

  def auth_token
    token_creator = AuthTokenCreator.create_with_defaults(@user)
    hash = token_creator.token_in_hash
    "Bearer #{hash[:access_token]}"
  end
end
