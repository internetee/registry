# frozen_string_literal: true

module Shunter
  module Adapters
    class Memory
      attr_reader :store

      def initialize(_options = {})
        @@store ||= {}
      end

      def find_counter(key)
        @@store[key]
      end

      def write_counter(key)
        @@store[key] = 1
      end

      def increment_counter(key)
        @@store[key] += 1
      end

      def clear!
        @@store = {}
      end

      def expire_counter(_key, _timespan); end
    end
  end
end
