require 'test_helper'

class RegistrantUserTest < ActiveSupport::TestCase
  Company = Struct.new(:registration_number, :company_name)

  def setup
    super

    @user = users(:registrant)
  end

  def teardown
    super
  end

  def test_ident_helper_method
    assert_equal('1234', @user.ident)
  end

  def test_first_name_from_username
    user = RegistrantUser.new(username: 'John Doe')
    assert_equal 'John', user.first_name
  end

  def test_last_name_from_username
    user = RegistrantUser.new(username: 'John Doe')
    assert_equal 'Doe', user.last_name
  end

  def test_returns_country
    user = RegistrantUser.new(registrant_ident: 'US-1234')
    assert_equal Country.new('US'), user.country
  end

  def test_should_update_org_contact_if_data_from_business_registry_dismatch
    assert_equal 'US-1234', @user.registrant_ident
    org = contacts(:acme_ltd)
    org.ident_country_code = 'EE'
    org.save(validate: false)
    org.reload

    company = Company.new(org.ident, "ace")

    Spy.on(@user, :companies).and_return([company])
    @user.update_company_contacts
    org.reload

    assert_equal org.name, company.company_name
  end

  def test_queries_company_register_for_associated_companies
    assert_equal 'US-1234', @user.registrant_ident

    company = Company.new("acme", "ace")

    company_register = Minitest::Mock.new
    company_register.expect(:representation_rights, [company], [{ citizen_personal_code: '1234',
                                                                     citizen_country_code: 'USA' }])

    assert_equal [company], @user.companies(company_register)
    company_register.verify
  end

  def test_returns_contacts
    Contact.stub(:registrant_user_contacts, %w(john jane)) do
      assert_equal %w(john jane), @user.contacts
    end
  end

  def test_returns_direct_contacts
    Contact.stub(:registrant_user_direct_contacts, %w(john jane)) do
      assert_equal %w(john jane), @user.direct_contacts
    end
  end

  def test_returns_domains
    Domain.stub(:registrant_user_domains, %w(shop airport)) do
      assert_equal %w(shop airport), @user.domains
    end
  end

  def test_returns_administered_domains
    Domain.stub(:registrant_user_administered_domains, %w(shop airport)) do
      assert_equal %w(shop airport), @user.administered_domains
    end
  end
end
