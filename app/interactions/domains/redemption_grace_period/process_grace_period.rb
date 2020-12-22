module Domains
  module RedemptionGracePeriod
    class ProcessGracePeriod < Base
      object :domain,
             class: Domain

      def execute
        domain.statuses << DomainStatus::SERVER_HOLD
        to_stdout(process_msg)
        domain.save(validate: false)
      end

      private

      def process_msg
        "start_redemption_grace_period: #{domain.id} (#{domain.name}) #{domain.changes}"
      end
    end
  end
end
