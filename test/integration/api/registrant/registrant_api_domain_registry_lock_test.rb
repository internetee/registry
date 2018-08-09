require 'test_helper'
require 'auth_token/auth_token_creator'

class RegistrantApiDomainRegistryLockTest < ApplicationIntegrationTest
  def setup
    super

    @user = users(:registrant)
    @domain = domains(:airport)
    @auth_headers = { 'HTTP_AUTHORIZATION' => auth_token }
  end

  def test_can_lock_a_not_locked_domain
    assert(@domain.locked_by_registrant?)
  end

  def test_cannot_lock_an_already_locked_domain
    assert(@domain.locked_by_registrant?)
  end

  private

  def auth_token
    token_creator = AuthTokenCreator.create_with_defaults(@user)
    hash = token_creator.token_in_hash
    "Bearer #{hash[:access_token]}"
  end
end
