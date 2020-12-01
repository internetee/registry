module Domains
  module UpdateConfirm
    class ProcessUpdateRejected < Base
      def execute
        ActiveRecord::Base.transaction do
          RegistrantChangeMailer.rejected(domain: domain,
                                          registrar: domain.registrar,
                                          registrant: domain.registrant).deliver_now

          notify_registrar(:poll_pending_update_rejected_by_registrant)

          preclean_pendings
          clean_pendings!
          domain.save!
        end
      end
    end
  end
end
