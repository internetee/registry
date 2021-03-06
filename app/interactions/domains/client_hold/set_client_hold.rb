module Domains
  module ClientHold
    class SetClientHold < Base
      def execute
        to_stdout('Setting client_hold to domains\n')

        ::PaperTrail.request.whodunnit = "cron - #{self.class.name}"

        ::Domain.force_delete_scheduled.each do |domain|
          Domains::ClientHold::ProcessClientHold.run(domain: domain)
        end

        to_stdout('All client_hold setting are done\n')
      end
    end
  end
end
