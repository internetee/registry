require 'test_helper'

class DeathRegistryDeceasedDomainContactsTest < ActiveSupport::TestCase
  Lookup = Struct.new(:deceased_idents) do
    def deceased?(ident)
      deceased_idents.include?(ident)
    end
  end

  DECEASED_IDENT = '49001010000'.freeze

  setup do
    @lookup = Lookup.new([DECEASED_IDENT])
    @deceased = contacts(:jane)
    @deceased.update_columns(ident: DECEASED_IDENT, ident_type: 'priv', ident_country_code: 'EE',
                             death_date: Date.new(2026, 1, 1))
  end

  def test_removes_deceased_tech_contact
    domain = domains(:shop)
    domain_contacts(:shop_jane).update_columns(type: 'TechDomainContact')

    assert_difference -> { domain.versions.count } do
      call
    end

    assert_not_includes domain.reload.tech_contacts, @deceased
    assert Notification.exists?(text: 'Tech contact jane-001 was removed from domain shop.test because, ' \
                                      'according to the Estonian Population Register, the person has died. ' \
                                      'Add a new tech contact if needed.')
  end

  def test_removes_deceased_admin_contact_of_private_registrant
    domain = domains(:shop)
    assert domain.registrant.priv?

    call

    assert_not_includes domain.reload.admin_contacts, @deceased
    assert_not domain.force_delete_scheduled?
    assert Notification.exists?(text: 'Admin contact jane-001 was removed from domain shop.test because, ' \
                                      'according to the Estonian Population Register, the person has died.')
  end

  def test_starts_soft_force_delete_when_last_admin_contact_of_organisation_dies
    domain = domains(:library)
    domain_contacts(:library_acme_admin).update_columns(contact_id: @deceased.id)

    call

    domain.reload
    assert_includes domain.admin_contacts, @deceased
    assert domain.force_delete_scheduled?
    assert_equal 'soft', domain.force_delete_type
    assert_equal 'deceased_admin_contact', domain.template_name
    assert_equal 'Admin contact jane-001 has died', domain.status_notes[DomainStatus::FORCE_DELETE]
    assert_includes domain.statuses, DomainStatus::SERVER_RENEW_PROHIBITED
    assert Notification.where('text LIKE ?', 'Force delete set on domain library.test. Admin contact jane-001 ' \
                                             'has died according to the Estonian Population Register.%').exists?
  end

  def test_removes_deceased_admin_contact_when_organisation_has_another
    domain = domains(:library)
    domain_contacts(:library_acme_admin).update_columns(contact_id: @deceased.id)
    domain.admin_domain_contacts.create!(contact: contacts(:william))

    call

    domain.reload
    assert_equal [contacts(:william)], domain.admin_contacts
    assert_not domain.force_delete_scheduled?
  end

  def test_starts_soft_force_delete_when_only_admin_contact_of_minor_dies
    domain = domains(:shop)
    domain.registrant.update_columns(ident: "5#{(Time.zone.today - 10.years).strftime('%y%m%d')}0000",
                                     ident_type: 'priv', ident_country_code: 'EE')
    assert domain.registrant.underage?

    call

    assert_equal 'deceased_admin_contact', domain.reload.template_name
    assert_includes domain.admin_contacts, @deceased
  end

  def test_leaves_domain_with_existing_force_delete_alone
    domain = domains(:library)
    domain_contacts(:library_acme_admin).update_columns(contact_id: @deceased.id)
    domain.schedule_force_delete(type: :fast_track, reason: 'invalid_company')

    call

    assert_equal 'fast_track', domain.reload.force_delete_type
    assert_includes domain.admin_contacts, @deceased
  end

  def test_clears_death_date_of_person_no_longer_in_registry
    @lookup = Lookup.new([])

    call

    assert_nil @deceased.reload.death_date
    assert_includes domains(:shop).reload.admin_contacts, @deceased
  end

  private

  def call
    DeathRegistry::DeceasedDomainContacts.new(lookup: @lookup).call
  end
end
