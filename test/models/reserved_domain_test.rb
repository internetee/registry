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

  def test_create_reserved_domain_with_punycode_name
    reserved_domain = ReservedDomain.create(name: 'xn--4ca7aey.test')
    assert reserved_domain.valid?
  end

  def test_create_reserved_domain_with_unicode_name
    reserved_domain = ReservedDomain.create(name: 'õäöü.test')
    assert reserved_domain.valid?
  end

  def test_cannot_create_the_same_domain_twicde_with_punycode_and_unicode
    punycode_reserved_domain = ReservedDomain.new(name: 'xn--4ca7aey.test')
    assert punycode_reserved_domain.valid?
    punycode_reserved_domain.save && punycode_reserved_domain.reload

    unicode_reserved_domain = ReservedDomain.new(name: 'õäöü.test')
    assert_not unicode_reserved_domain.valid?
  end
end
