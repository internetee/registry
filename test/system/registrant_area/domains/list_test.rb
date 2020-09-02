require 'application_system_test_case'

CompanyRegisterClientStub = Struct.new(:any_method) do
  def representation_rights(citizen_personal_code:, citizen_country_code:)
    raise CompanyRegister::NotAvailableError
  end
end

class RegistrantAreaDomainListTest < ApplicationSystemTestCase
  setup do
    @user = users(:registrant)
    sign_in @user

    @domain = domains(:shop)
  end

  def test_show_domain_list
    visit registrant_domains_url
    assert_link 'shop.test', href: registrant_domain_path(@domain)
    assert_link 'John', href: registrant_domain_contact_path(@domain, @domain.registrant)
    assert_link 'Best Names', href: registrant_registrar_path(@domain.registrar)
    assert_text l(Time.zone.parse('2010-07-05'))
    assert_css '.domains .domain', count: 4
  end

  def test_do_not_show_domains_of_other_registrant_users
    visit registrant_domains_url
    assert_no_text 'metro.test'
  end

  def test_notification_when_company_register_is_unavailable
    CompanyRegister::Client.stub(:new, CompanyRegisterClientStub.new) do
      visit registrant_domains_url
    end

    assert_text 'Company register is unavailable. Domains and contacts associated via' \
      ' organizations are not shown.'
  end

  def test_show_direct_domains_when_company_register_is_unavailable
    assert_equal 'US-1234', @user.registrant_ident

    contact = contacts(:john)
    assert_equal '1234', contact.ident
    assert_equal Contact::PRIV, contact.ident_type
    assert_equal 'US', contact.ident_country_code

    assert_equal contact.becomes(Registrant), @domain.registrant
    assert_equal 'shop.test', @domain.name

    CompanyRegister::Client.stub(:new, CompanyRegisterClientStub.new) do
      visit registrant_domains_url
    end

    assert_text 'shop.test'
  end
end