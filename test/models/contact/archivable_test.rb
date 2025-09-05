require 'test_helper'

class ArchivableContactTest < ActiveSupport::TestCase
  setup do
    @contact = contacts(:john)
  end

  def test_contact_is_archivable_when_it_was_linked_and_inactivity_period_has_passed
    Version::DomainVersion.stub(:was_contact_linked?, true) do
      Version::DomainVersion.stub(:contact_unlinked_more_than?, true) do
        assert @contact.archivable?
      end
    end
  end

  def test_contact_is_archivable_when_it_was_never_linked_and_inactivity_period_has_passed
    Setting.orphans_contacts_in_months = 0
    @contact.created_at = Time.zone.parse('2010-07-05 00:00:00')
    travel_to Time.zone.parse('2010-07-05 00:00:01')

    Version::DomainVersion.stub(:was_contact_linked?, false) do
      assert @contact.archivable?
    end
  end

  def test_contact_is_not_archivable_when_it_was_never_linked_and_inactivity_period_has_not_passed
    Setting.orphans_contacts_in_months = 5
    @contact.created_at = Time.zone.parse('2010-07-05')
    travel_to Time.zone.parse('2010-07-05')

    Version::DomainVersion.stub(:contact_unlinked_more_than?, false) do
      assert_not @contact.archivable?
    end
  end

  def test_contact_is_not_archivable_when_it_was_ever_linked_but_linked_within_inactivity_period
    Version::DomainVersion.stub(:was_contact_linked?, true) do
      Version::DomainVersion.stub(:contact_unlinked_more_than?, false) do
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

  def test_sends_poll_msg_to_registrar_after_archivation
    contact = archivable_contact
    registrar = contact.registrar
    contact.archive

    assert_equal(I18n.t(:contact_has_been_archived, contact_code: contact.code,
                                                    orphan_months: Setting.orphans_contacts_in_months),
                 registrar.notifications.last.text)
  end

  def test_write_to_registrar_log_creates_log_file
    contact = archivable_contact
    registrar = contact.registrar
    log_dir = '/tmp/test_logs'
    ENV['contact_archivation_log_file_dir'] = log_dir

    # Using Stub to avoid creating the log file in the filesystem
    FileUtils.stub(:mkdir_p, true) do
      file_mock = Minitest::Mock.new

      file_mock.expect(:write, nil) do |arg|
        arg.to_s.include?(contact.code)
      end

      file_mock.expect(:close, nil)

      File.stub(:new, file_mock) do
        contact.archive(extra_log: true, verified: true, notify: false)
      end

      assert_mock file_mock
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

  def unarchivable_contact
    Setting.orphans_contacts_in_months = 1188
    @contact
  end
end
