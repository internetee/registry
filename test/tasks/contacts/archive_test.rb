require 'test_helper'

class ArchiveContactsTaskTest < ActiveSupport::TestCase
  def test_archives_inactive_contacts
    eliminate_effect_of_all_contacts_except(archivable_contact)

    assert_difference 'Contact.count', -1 do
      capture_io { run_task }
    end
  end

  def test_output
    contact = archivable_contact
    eliminate_effect_of_all_contacts_except(contact)

    expected_output = "Contact ##{contact.id} (code: #{contact.code}) is archived\n" \
                      "Archived total: 1\n"
    assert_output(expected_output) { run_task }
  end

  private

  def archivable_contact
    contact = contacts(:john)
    Contact.inactivity_period = 0.seconds
    DomainVersion.delete_all

    other_contact = contacts(:william)
    assert_not_equal other_contact, contact
    Domain.update_all(registrant_id: other_contact.id)

    DomainContact.delete_all

    contact
  end

  def eliminate_effect_of_all_contacts_except(contact)
    Contact.connection.disable_referential_integrity do
      Contact.delete_all("id != #{contact.id}")
    end
  end

  def run_task
    Rake::Task['contacts:archive'].execute
  end
end
