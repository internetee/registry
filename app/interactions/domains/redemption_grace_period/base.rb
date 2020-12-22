module Domains
  module RedemptionGracePeriod
    class Base < ActiveInteraction::Base
      def to_stdout(message)
        time = Time.zone.now.utc
        STDOUT << "#{time} - #{message}\n" unless Rails.env.test?
      end
    end
  end
end
