class DeleteOrphanedRegistrantVerifications < ActiveRecord::Migration[5.1]
  def up
    # orphaned_registrant_verifications = RegistrantVerification.where.not(domain_id: Domain.ids)
    # orphaned_registrant_verification_count = orphaned_registrant_verifications.count
    # processed_registrant_verification_count = 0
    #
    # orphaned_registrant_verifications.each do |registrant_verification|
    #   registrant_verification.destroy!
    #   processed_registrant_verification_count += 1
    # end
    #
    # puts "Processed: #{processed_registrant_verification_count} out of" \
    #   " #{orphaned_registrant_verification_count}"
  end

  def down
  end
end
