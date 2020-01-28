module Concerns
  module Job
    module ForceDelete
      extend ActiveSupport::Concern

      class_methods do
        def start_client_hold
          log_prepare_client_hold

          ::PaperTrail.whodunnit = "cron - #{__method__}"

          ::Domain.force_delete_scheduled.each do |domain|
            proceed_client_hold(domain: domain)
          end

          log_end_end_force_delete_job
        end

        def proceed_client_hold(domain:)
          notify_on_grace_period(domain) if domain.should_notify_on_soft_force_delete?
          return unless domain.client_holdable?

          domain.statuses << DomainStatus::CLIENT_HOLD
          log_start_client_hold(domain)

          domain.save(validate: false)
          notify_client_hold(domain)

          log_end_end_client_hold(domain)
        end
      end
    end
  end
end
