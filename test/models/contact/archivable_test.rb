require 'test_helper'

class ArchivableContactTest < ActiveSupport::TestCase
  setup do
    @contact = contacts(:john)
  end

  def test_contact_is_archivable_when_it_was_linked_and_inactivity_period_has_passed
    DomainVersion.stub(:was_contact_linked?, true) do
      DomainVersion.stub(:contact_unlinked_more_than?, true) do
        assert @contact.archivable?
      end
    end
  end

  def test_contact_is_archivable_when_it_was_never_linked_and_inactivity_period_has_passed
    Setting.orphans_contacts_in_months = 0
    @contact.created_at = Time.zone.parse('2010-07-05 00:00:00')
    travel_to Time.zone.parse('2010-07-05 00:00:01')

    DomainVersion.stub(:was_contact_linked?, false) do
      assert @contact.archivable?
    end
  end

  def test_contact_is_not_archivable_when_it_was_never_linked_and_inactivity_period_has_not_passed
    Setting.orphans_contacts_in_months = 5
    @contact.created_at = Time.zone.parse('2010-07-05')
    travel_to Time.zone.parse('2010-07-05')

    DomainVersion.stub(:contact_unlinked_more_than?, false) do
      assert_not @contact.archivable?
    end
  end

  def test_contact_is_not_archivable_when_it_was_ever_linked_but_linked_within_inactivity_period
    DomainVersion.stub(:was_contact_linked?, true) do
      DomainVersion.stub(:contact_unlinked_more_than?, false) do
        assert_not @contact.archivable?
      end
    end
  end

  def test_archives_contact
    contact = archivable_contact

    assert_difference 'Contact.count', -1 do
      contact.archive
    end
  end

  def test_unarchivable_contact_cannot_be_archived
    contact = unarchivable_contact

    e = assert_raises do
      contact.archive
    end
    assert_equal 'Contact cannot be archived', e.message
  end

  private

  def archivable_contact
    contact = contacts(:john)
    Setting.orphans_contacts_in_months = 0
    DomainVersion.delete_all

    other_contact = contacts(:william)
    assert_not_equal other_contact, contact
    Domain.update_all(registrant_id: other_contact.id)

    DomainContact.delete_all

    contact
  end

  def unarchivable_contact
    Setting.orphans_contacts_in_months = 1188
    @contact
  end
end
