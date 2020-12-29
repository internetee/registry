module Domains
  module ExpiredPendings
    class ProcessClean < Base
      object :domain,
             class: Domain

      def execute
        check_notify
        clean_pendings

        to_stdout("DomainCron.clean_expired_pendings: ##{domain.id} (#{domain.name})")
        UpdateWhoisRecordJob.enqueue domain.name, 'domain'
      end

      private

      def notify_pending_update
        RegistrantChangeMailer.expired(domain: domain,
                                       registrar: domain.registrar,
                                       registrant: domain.registrant).deliver_later
      end

      def notify_pending_delete
        DomainDeleteMailer.expired(domain).deliver_later
      end

      def clean_pendings
        clean_verification_data
        domain.pending_json = {}
        clean_statuses
        domain.save
      end

      def statuses_to_clean
        [DomainStatus::PENDING_DELETE_CONFIRMATION,
         DomainStatus::PENDING_UPDATE,
         DomainStatus::PENDING_DELETE]
      end

      def clean_statuses
        domain.statuses = domain.statuses - statuses_to_clean
        domain.status_notes[DomainStatus::PENDING_UPDATE] = ''
        domain.status_notes[DomainStatus::PENDING_DELETE] = ''
      end

      def clean_verification_data
        domain.registrant_verification_token = nil
        domain.registrant_verification_asked_at = nil
      end

      def check_notify
        notify_pending_update if domain.pending_update?

        return unless domain.pending_delete? || domain.pending_delete_confirmation?

        notify_pending_delete
      end
    end
  end
end
