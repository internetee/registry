# frozen_string_literal: true

module Shunter
  module Adapters
    class Redis
      attr_reader :redis

      def initialize(options)
        @redis = ::Redis.new(options)
      end

      def find_counter(key)
        @redis.get(key)
      end

      def write_counter(key)
        @redis.set(key, 1)
      end

      def increment_counter(key)
        @redis.incr(key)
      end

      def expire_counter(key, timespan)
        @redis.expire(key, timespan)
      end
    end
  end
end
