module Domains
  module DeleteConfirm
    class ProcessDeleteConfirmed < Base
      def execute
        notify_registrar(:poll_pending_delete_confirmed_by_registrant)
        domain.apply_pending_delete!
        raise_errors!(domain)
      end

      def apply_pending_delete!
        preclean_pendings
        clean_pendings!
        DomainDeleteMailer.accepted(domain).deliver_now
        domain.set_pending_delete!
      end

      def set_pending_delete!
        unless domain.pending_deletable?
          add_epp_error
          return
        end

        domain.delete_date = delete_date
        domain.statuses << DomainStatus::PENDING_DELETE
        set_server_hold if server_holdable?
        domain.save(validate: false)
      end

      def set_server_hold
        domain.statuses << DomainStatus::SERVER_HOLD
        domain.outzone_at = Time.current
      end

      def server_holdable?
        return false if domain.statuses.include?(DomainStatus::SERVER_HOLD)
        return false if domain.statuses.include?(DomainStatus::SERVER_MANUAL_INZONE)

        true
      end

      def delete_date
        Time.zone.today + Setting.redemption_grace_period.days + 1.day
      end

      def add_epp_error
        domain.add_epp_error('2304', nil, nil, I18n.t(:object_status_prohibits_operation))
      end
    end
  end
end
