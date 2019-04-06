require 'test_helper'

class RegistrantAreaDomainDetailsTest < ApplicationSystemTestCase
  setup do
    sign_in users(:registrant)
    @domain = domains(:shop)
  end

  def test_general_data
    @domain.update_columns(force_delete_date: '2010-07-08', statuses: [DomainStatus::FORCE_DELETE])

    visit registrant_domain_url(@domain)

    assert_text 'Name shop.test'
    assert_text "Registered at #{l Time.zone.parse('2010-07-04')}"
    assert_link 'Best Names', href: registrant_registrar_path(@domain.registrar)

    assert_text 'Transfer code'
    assert_css('[value="65078d5"]')

    assert_text "Valid to #{l Time.zone.parse('2010-07-05')}"
    assert_text "Outzone at #{l Time.zone.parse('2010-07-06')}"
    assert_text "Delete at #{l Time.zone.parse('2010-07-07')}"
    assert_text "Force delete date #{l Date.parse('2010-07-08')}"
  end

  def test_registrant
    visit registrant_domain_url(@domain)
    assert_link 'John', href: registrant_domain_contact_path(@domain, @domain.registrant)
    assert_text 'Code john-001'
    assert_text 'Ident 1234'
    assert_text 'Email john@inbox.test'
    assert_text 'Phone +555.555'
  end

  def test_admin_contacts
    visit registrant_domain_url(@domain)

    within('.admin-domain-contacts') do
      assert_link 'Jane', href: registrant_domain_contact_path(@domain, contacts(:jane))
      assert_text 'jane-001'
      assert_text 'jane@mail.test'
      assert_css '.admin-domain-contact', count: 1
    end
  end

  def test_tech_contacts
    visit registrant_domain_url(@domain)

    within('.tech-domain-contacts') do
      assert_link 'William', href: registrant_domain_contact_path(@domain, contacts(:william))
      assert_text 'william-001'
      assert_text 'william@inbox.test'
      assert_css '.tech-domain-contact', count: 2
    end
  end

  def test_registrant_user_cannot_access_domains_of_other_users
    suppress(ActiveRecord::RecordNotFound) do
      visit registrant_domain_url(domains(:metro))
      assert_response :not_found
      assert_no_text 'metro.test'
    end
  end

  def test_confirmation_url
    @domain.update!(registrant_verification_token: 'a01',
                    pending_json: { new_registrant_email: 'any' },
                    statuses: [DomainStatus::PENDING_UPDATE])

    visit registrant_domain_url(@domain)
    click_on 'pendingUpdate'

    assert_field nil, with: registrant_domain_update_confirm_url(@domain, token: 'a01')
  end
end