module Domains
  module ExpirePeriod
    class Base < ActiveInteraction::Base
      def to_stdout(message)
        time = Time.zone.now.utc
        $stdout << "#{time} - #{message}\n" unless Rails.env.test?
      end

      def logger
        @logger ||= Logger.new(Rails.root.join('log', 'domain_expire_period.log'))
      end
    end
  end
end
