require 'test_helper'

class ReservedDomainTest < ActiveSupport::TestCase
  setup do
    @reserved_domain = reserved_domains(:one)
  end

  def test_fixture_is_valid
    assert @reserved_domain.valid?
  end

  def test_aliases_registration_code_to_password
    reserved_domain = ReservedDomain.new(password: 'reserved-001')
    assert_equal 'reserved-001', reserved_domain.registration_code
  end
end
