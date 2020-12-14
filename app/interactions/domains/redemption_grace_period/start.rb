module Domains
  module RedemptionGracePeriod
    class Start < Base
      def execute
        to_stdout('Setting server_hold to domains')

        ::PaperTrail.request.whodunnit = "cron - #{self.class.name}"
        count = 0

        Domain.outzone_candidates.each do |domain|
          next unless domain.server_holdable?

          count += 1
          Domains::RedemptionGracePeriod::ProcessGracePeriod.run(domain: domain)
        end
        to_stdout("Successfully set server_hold to #{count} of domains")
      end
    end
  end
end
