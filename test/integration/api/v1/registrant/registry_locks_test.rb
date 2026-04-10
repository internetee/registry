require 'test_helper'
require 'auth_token/auth_token_creator'

class RegistrantApiV1RegistryLocksTest < ActionDispatch::IntegrationTest
  setup do
    Rails.cache.clear
    @user = users(:registrant)
  end

  def test_outage_does_not_use_listing_resolver_for_lock_path
    resolver_instantiated = false
    original_new = ListingCompanyCodesResolver.method(:new)

    ListingCompanyCodesResolver.define_singleton_method(:new) do |*args, **kwargs|
      resolver_instantiated = true
      original_new.call(*args, **kwargs)
    end

    domain = domains(:shop)
    post api_v1_registrant_domain_registry_lock_path(domain_uuid: domain.uuid),
         as: :json,
         headers: { 'HTTP_AUTHORIZATION' => auth_token }

    refute resolver_instantiated, 'ListingCompanyCodesResolver should not be used in registry_locks path'
  ensure
    ListingCompanyCodesResolver.define_singleton_method(:new, original_new)
  end

  def test_registry_locks_uses_live_flow_not_resolver_during_outage
    stub = Object.new
    stub.define_singleton_method(:representation_rights) do |citizen_personal_code:, citizen_country_code:|
      raise CompanyRegister::NotAvailableError
    end

    # metro domain is owned by jack (org ident 12345678), not accessible to registrant user
    domain = domains(:metro)

    CompanyRegister::Client.stub(:new, stub) do
      post api_v1_registrant_domain_registry_lock_path(domain_uuid: domain.uuid),
           as: :json,
           headers: { 'HTTP_AUTHORIZATION' => auth_token }
    end

    # metro is not found because companies returns [] during outage via RegistrantUser#companies
    # and jack is not a direct contact of the registrant user
    assert_response :not_found
  end

  private

  def auth_token
    token_creator = AuthTokenCreator.create_with_defaults(@user)
    hash = token_creator.token_in_hash
    "Bearer #{hash[:access_token]}"
  end
end
