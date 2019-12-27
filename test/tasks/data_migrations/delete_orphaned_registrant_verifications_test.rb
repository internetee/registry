require 'test_helper'

class ArchiveOrphanedRegistrantVerificationsTest < ActiveSupport::TestCase
  def test_deletes_orphaned_registrant_verifications
    create_orphaned_registrant_verification

    assert_difference 'RegistrantVerification.count', -1 do
      capture_io do
        run_task
      end
    end
  end

  def test_keeps_non_orphaned_registrant_verifications_intact
    assert_no_difference 'RegistrantVerification.count' do
      capture_io do
        run_task
      end
    end
  end

  def test_output
    create_orphaned_registrant_verification

    assert_output "Processed: 1 out of 1\n" do
      run_task
    end
  end

  private

  def create_orphaned_registrant_verification
    non_existent_domain_id = 55
    assert_not_includes Domain.ids, non_existent_domain_id

    RegistrantVerification.connection.disable_referential_integrity do
      registrant_verifications(:one).update_columns(domain_id: non_existent_domain_id)
    end
  end

  def run_task
    Rake::Task['data_migrations:delete_orphaned_registrant_verifications'].execute end
end
