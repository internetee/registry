module Domains
  module UpdateConfirm
    class ProcessUpdateRejected < Base
      def execute
        operation_id = PendingOperationEvent.operation_id(domain.registrant_verification_token)
        ActiveRecord::Base.transaction do
          RegistrantChangeMailer.rejected(domain: domain,
                                          registrar: domain.registrar,
                                          registrant: domain.registrant).deliver_now

          notify_registrar(:poll_pending_update_rejected_by_registrant)

          preclean_pendings
          clean_pendings!
          PendingOperationEvent.record(domain: domain, event: 'denied', operation_id: operation_id, operation: RegistrantVerification::DOMAIN_REGISTRANT_CHANGE, actor: actor || { type: 'system' })
        end
      end
    end
  end
end
