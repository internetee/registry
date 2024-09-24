require 'test_helper'
require 'rake'

class ArchiveContactsTaskTest < ActiveSupport::TestCase
  def test_archives_inactive_contacts
    eliminate_effect_of_all_contacts_except(archivable_contact)

    assert_difference 'Contact.count', -1 do
      capture_io { run_task }
    end
  end

  private

  def archivable_contact
    contact = contacts(:john)
    Setting.orphans_contacts_in_months = 0
    Version::DomainVersion.delete_all

    other_contact = contacts(:william)
    assert_not_equal other_contact, contact
    Domain.update_all(registrant_id: other_contact.id)

    DomainContact.delete_all

    contact
  end

  def eliminate_effect_of_all_contacts_except(contact)
    Contact.connection.disable_referential_integrity do
      Contact.where("id != #{contact.id}").delete_all
    end
  end

  def run_task
    Rake::Task['contacts:archive'].execute
  end
end
