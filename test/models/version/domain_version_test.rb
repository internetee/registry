require 'test_helper'

class DomainVersionTest < ActiveSupport::TestCase
  setup do
    @domain_version = log_domains(:one)
    @contact = contacts(:john)
  end

  def test_was_contact_linked_returns_true_when_contact_was_used_as_registrant
    @domain_version.update!(children: { admin_contacts: [],
                                        tech_contacts: [],
                                        registrant: [@contact.id] })

    assert DomainVersion.was_contact_linked?(@contact)
  end

  def test_was_contact_linked_returns_true_when_contact_was_used_as_admin_contact
    @domain_version.update!(children: { admin_contacts: [@contact.id],
                                        tech_contacts: [],
                                        registrant: [] })

    assert DomainVersion.was_contact_linked?(@contact)
  end

  def test_was_contact_linked_returns_true_when_contact_was_used_as_tech_contact
    @domain_version.update!(children: { admin_contacts: [],
                                        tech_contacts: [@contact.id],
                                        registrant: [] })

    assert DomainVersion.was_contact_linked?(@contact)
  end

  def test_was_contact_linked_returns_false_when_contact_was_not_used
    @domain_version.update!(children: { admin_contacts: [],
                                        tech_contacts: [],
                                        registrant: [] })

    assert_not DomainVersion.was_contact_linked?(@contact)
  end

  def test_contact_unlinked_more_than_returns_true_when_contact_was_linked_as_registrant_more_than_given_period
    @domain_version.update!(created_at: Time.zone.parse('2010-07-04 00:00:00'),
                            children: { admin_contacts: [],
                                        tech_contacts: [],
                                        registrant: [@contact.id] })
    travel_to Time.zone.parse('2010-07-05 00:00:01')

    assert DomainVersion.contact_unlinked_more_than?(contact: @contact, period: 1.day)
  end

  def test_contact_unlinked_more_than_given_period_as_admin_contact
    @domain_version.update!(created_at: Time.zone.parse('2010-07-04 00:00:00'),
                            children: { admin_contacts: [1, @contact.id],
                                        tech_contacts: [],
                                        registrant: [] })
    travel_to Time.zone.parse('2010-07-05 00:00:01')

    assert DomainVersion.contact_unlinked_more_than?(contact: @contact, period: 1.day)
  end

  def test_contact_unlinked_more_than_given_period_as_tech_contact
    @domain_version.update!(created_at: Time.zone.parse('2010-07-04 00:00:00'),
                            children: { admin_contacts: [],
                                        tech_contacts: [1, @contact.id],
                                        registrant: [] })
    travel_to Time.zone.parse('2010-07-05 00:00:01')

    assert DomainVersion.contact_unlinked_more_than?(contact: @contact, period: 1.day)
  end

  def test_contact_linked_within_given_period_as_registrant
    @domain_version.update!(created_at: Time.zone.parse('2010-07-05'),
                            children: { admin_contacts: [],
                                        tech_contacts: [],
                                        registrant: [@contact.id] })
    travel_to Time.zone.parse('2010-07-05')

    assert_not DomainVersion.contact_unlinked_more_than?(contact: @contact, period: 1.day)
  end

  def test_contact_linked_within_given_period_as_admin_contact
    @domain_version.update!(created_at: Time.zone.parse('2010-07-05'),
                            children: { admin_contacts: [1, @contact.id],
                                        tech_contacts: [],
                                        registrant: [] })
    travel_to Time.zone.parse('2010-07-05')

    assert_not DomainVersion.contact_unlinked_more_than?(contact: @contact, period: 1.day)
  end

  def test_contact_linked_within_given_period_as_tech_contact
    @domain_version.update!(created_at: Time.zone.parse('2010-07-05'),
                            children: { admin_contacts: [],
                                        tech_contacts: [1, @contact.id],
                                        registrant: [] })
    travel_to Time.zone.parse('2010-07-05')

    assert_not DomainVersion.contact_unlinked_more_than?(contact: @contact, period: 1.day)
  end

  def test_contact_was_never_linked
    DomainVersion.delete_all
    assert_not DomainVersion.contact_unlinked_more_than?(contact: @contact, period: 1.day)
  end
end