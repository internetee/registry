module Concerns
  module Job
    module ForceDeleteLogging
      extend ActiveSupport::Concern

      class_methods do
        def log_prepare_client_hold
          return if Rails.env.test?

          STDOUT << "#{Time.zone.now.utc} - Setting client_hold to domains\n"
        end

        def log_start_client_hold(domain)
          return if Rails.env.test?

          STDOUT << "#{Time.zone.now.utc} DomainCron.start_client_hold: ##{domain.id} "\
                    "(#{domain.name}) #{domain.changes}\n"
        end

        def log_end_end_client_hold(domain)
          return if Rails.env.test?

          STDOUT << "#{Time.zone.now.utc} - Successfully set client_hold on (#{domain.name})"
        end

        def log_end_end_force_delete_job
          return if Rails.env.test?

          STDOUT << "#{Time.zone.now.utc} - All client_hold setting are done\n"
        end
      end
    end
  end
end
