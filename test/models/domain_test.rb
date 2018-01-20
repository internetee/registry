require 'test_helper'

class DomainTest < ActiveSupport::TestCase
  def setup
    @domain = domains(:shop)
  end

  def test_transfers_domain
    old_auth_info = @domain.auth_info
    new_registrar = registrars(:goodnames)
    @domain.transfer(new_registrar)

    assert_equal new_registrar, @domain.registrar
    refute_same @domain.auth_info, old_auth_info
  end
end
