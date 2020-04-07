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

  def test_stores_history
    @reserved_domain.name = 'reserved2.test'

    assert_difference '@reserved_domain.versions.count', 1 do
      @reserved_domain.save!
    end
  end
end
