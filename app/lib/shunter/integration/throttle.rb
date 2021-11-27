# frozen_string_literal: true

require 'active_support/concern'

module Shunter
  module Integration
    module Throttle
      extend ActiveSupport::Concern

      included do |base|
        actions = base.const_defined?('THROTTLED_ACTIONS') && base.const_get('THROTTLED_ACTIONS')
        return if actions.blank?

        around_action :throttle, only: actions

        def throttle
          if throttled_user.blank? || !Shunter.feature_enabled?
            yield if block_given?
            return
          end

          user_id = throttled_user.id

          shunter = Shunter::Base.new(conn_options: connection_options, user_id: user_id)
          if shunter.throttle
            logger.info "Request from #{throttled_user.class}/#{throttled_user.id} is coming through throttling"
            yield if block_given?
          else
            logger.info "Too many requests from #{throttled_user.class}/#{throttled_user.id}."
            raise Shunter::ThrottleError
          end
        end
      end

      def connection_options
        Shunter::BASE_CONNECTION
      end

      def logger
        Shunter::BASE_LOGGER
      end
    end
  end
end
