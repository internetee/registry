require 'test_helper'

class DomainTest < ActiveSupport::TestCase
  setup do
    @domain = domains(:shop)
  end

  def test_valid_fixture_is_valid
    assert @domain.valid?
  end

  def test_invalid_fixture_is_invalid
    assert domains(:invalid).invalid?
  end

  def test_domain_name
    domain = Domain.new(name: 'shop.test')
    assert_equal 'shop.test', domain.domain_name.to_s
  end

  def test_returns_registrant_user_domains_by_registrant
    registrant = contacts(:john).becomes(Registrant)
    assert_equal registrant, @domain.registrant
    registrant_user = RegistrantUser.new

    registrant_user.stub(:contacts, [registrant]) do
      assert_includes Domain.registrant_user_domains(registrant_user), @domain
    end
  end

  def test_returns_registrant_user_domains_by_contact
    contact = contacts(:jane)
    assert_not_equal contact.becomes(Registrant), @domain.registrant
    assert_includes @domain.contacts, contact
    registrant_user = RegistrantUser.new

    registrant_user.stub(:contacts, [contact]) do
      assert_includes Domain.registrant_user_domains(registrant_user), @domain
    end
  end

  def test_returns_registrant_user_administered_domains_by_registrant
    registrant = contacts(:john).becomes(Registrant)
    assert_equal registrant, @domain.registrant
    registrant_user = RegistrantUser.new

    registrant_user.stub(:contacts, [registrant]) do
      assert_includes Domain.registrant_user_administered_domains(registrant_user), @domain
    end
  end

  def test_returns_registrant_user_administered_domains_by_administrative_contact
    contact = contacts(:jane)
    assert_not_equal contact.becomes(Registrant), @domain.registrant
    assert_includes @domain.admin_contacts, contact
    registrant_user = RegistrantUser.new

    registrant_user.stub(:contacts, [contact]) do
      assert_includes Domain.registrant_user_administered_domains(registrant_user), @domain
    end
  end

  def test_does_not_return_registrant_user_administered_domains_by_technical_contact
    contact = contacts(:william)
    assert_not_equal contact.becomes(Registrant), @domain.registrant
    assert_includes @domain.tech_contacts, contact
    registrant_user = RegistrantUser.new

    registrant_user.stub(:contacts, [contact]) do
      assert_not_includes Domain.registrant_user_administered_domains(registrant_user), @domain
    end
  end
end