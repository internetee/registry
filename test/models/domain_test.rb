require 'test_helper'

class DomainTest < ActiveSupport::TestCase
  def setup
    @domain = domains(:shop)
  end

  def test_validates
    assert @domain.valid?
  end

  def test_generates_random_auth_info_if_new
    domain = Domain.new
    another_domain = Domain.new

    refute_empty domain.auth_info
    refute_empty another_domain.auth_info
    refute_equal domain.auth_info, another_domain.auth_info
  end

  def test_does_not_regenerate_auth_info_if_persisted
    original_auth_info = @domain.auth_info
    @domain.save!
    @domain.reload
    assert_equal original_auth_info, @domain.auth_info
  end

  def test_transfers_domain
    old_auth_info = @domain.auth_info
    new_registrar = registrars(:goodnames)
    @domain.transfer(new_registrar)

    assert_equal new_registrar, @domain.registrar
    refute_same @domain.auth_info, old_auth_info
  end
end
