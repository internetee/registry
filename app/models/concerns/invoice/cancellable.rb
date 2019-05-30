module Concerns
  module Invoice
    module Cancellable
      extend ActiveSupport::Concern

      included do
        scope :non_cancelled, -> { where(cancelled_at: nil) }
      end

      def cancellable?
        unpaid? && not_cancelled?
      end

      def cancel
        raise 'Invoice cannot be cancelled' unless cancellable?

        update!(cancelled_at: Time.zone.now)
      end

      def cancelled?
        cancelled_at
      end

      def not_cancelled?
        !cancelled?
      end
    end
  end
end
