module Domains
  module ExpiredPendings
    class CleanAll < Base
      def execute
        to_stdout('Clean expired domain pendings')

        ::PaperTrail.request.whodunnit = "cron - #{self.class.name}"

        count = 0
        expired_pending_domains.each do |domain|
          log_error(domain) && next unless need_to_be_cleared?(domain)
          count += 1
          Domains::ExpiredPendings::ProcessClean.run(domain: domain)
        end
        to_stdout("Successfully cancelled #{count} domain pendings")
      end

      private

      def need_to_be_cleared?(domain)
        domain.pending_update? || domain.pending_delete? || domain.pending_delete_confirmation?
      end

      def log_error(domain)
        to_stdout("ISSUE: DOMAIN #{domain.id}: #{domain.name} IS IN EXPIRED PENDING LIST, "\
                'but no pendingDelete/pendingUpdate state present!')
      end

      def expired_pending_domains
        expire_at = Setting.expire_pending_confirmation.hours.ago
        Domain.where('registrant_verification_asked_at <= ?', expire_at)
      end
    end
  end
end
