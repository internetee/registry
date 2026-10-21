module Domains
  module AutoRenew
    class Start < Base
      def execute
        ::PaperTrail.request(whodunnit: "cron - #{self.class.name}") do
          DomainAutoRenewal.due_for_closing.find_each do |cycle|
            isolated(cycle) { CloseCycle.run!(cycle: cycle) }
          end
          if Feature.auto_renew_enabled?
            Domain.where(auto_renew: true).expired.find_each do |domain|
              isolated(domain) { OpenCycle.run!(domain: domain) }
            end
          end
          DomainAutoRenewal.awaiting_funds.find_each do |cycle|
            isolated(cycle) { AttemptRenewal.run!(cycle: cycle) }
          end
        end
      end

      private

      def isolated(record)
        yield
      rescue StandardError => e
        logger.error("#{record.class} ##{record.id}: #{e.class}: #{e.message}\n#{e.backtrace.join("\n")}")
      end
    end
  end
end
