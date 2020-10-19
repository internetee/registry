module Domains
  module UpdateConfirm
    class ProcessUpdateConfirmed < Base
      def execute
        ActiveRecord::Base.transaction do
          old_registrant = domain.registrant
          notify_registrar(:poll_pending_update_confirmed_by_registrant)

          apply_pending_update!
          raise_errors!(domain)
          RegistrantChange.new(domain: domain, old_registrant: old_registrant).confirm
        end
      end

      def apply_pending_update!
        preclean_pendings
        update_domain
        clean_pendings!

        WhoisRecord.find_by(domain_id: domain.id)&.save # need to reload model
      end

      def update_domain
        frame_json = domain.pending_json['frame']
        frame = frame_json ? frame_json.with_indifferent_access : {}
        assign_domain_update_meta

        Actions::DomainUpdate.new(domain, frame, true).call
      end

      def assign_domain_update_meta
        user = ApiUser.find(domain.pending_json['current_user_id'])

        domain.upid = user.registrar.id if user.registrar
        domain.up_date = Time.zone.now
      end
    end
  end
end
