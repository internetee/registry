module Domains
  module ExpirePeriod
    class Start < Base
      def execute
        ::PaperTrail.request.whodunnit = "cron - #{self.class.name}"
        count = 0

        Domain.expired.each do |domain|
          next unless domain.expirable?

          count += 1
          Domains::ExpirePeriod::ProcessExpired.run(domain: domain)
        end

        to_stdout("Successfully expired #{count}")
      end
    end
  end
end
