# frozen_string_literal: true

module Shunter
  class Base
    attr_accessor :user_id, :adapter

    def initialize(options = {})
      @user_id = options[:user_id]
      adapter_klass = Shunter.default_adapter.constantize
      @adapter = adapter_klass.new(options[:conn_options])
    end

    def user_key
      "counting_#{@user_id}"
    end

    def blocked_user_key
      "blocked_#{@user_id}"
    end

    def throttle
      return false if blocked?

      valid_counter?
    end

    def blocked?
      adapter.find_counter(blocked_user_key).present?
    end

    def valid_counter?
      if adapter.find_counter(user_key)
        number_of_requests = adapter.increment_counter(user_key)
        if number_of_requests > allowed_requests.to_i
          init_counter(blocked_user_key)
          return false
        end
      else
        init_counter(user_key)
      end
      true
    end

    private

    def init_counter(key)
      adapter.write_counter(key)
      adapter.expire_counter(key, timespan)
    end

    def allowed_requests
      Shunter.default_threshold
    end

    def timespan
      Shunter.default_timespan
    end

    def logger
      Shunter::BASE_LOGGER
    end
  end
end
