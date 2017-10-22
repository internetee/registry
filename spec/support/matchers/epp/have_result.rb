module Matchers
  module EPP
    class HaveResultMatcher
      def initialize(expected)
        @expected = expected
      end

      def matches?(target)
        @target = target

        if @expected.message.present?
          @target.results.any? { |result| result.code == @expected.code && result.message == @expected.message }
        else
          @target.results.any? { |result| result.code == @expected.code }
        end
      end

      def failure_message
        "expected #{@target.results} to have result #{@expected.inspect}"
      end

      def failure_message_when_negated
        "expected #{@target.results} not to have result #{@expected.inspect}"
      end

      def description
        "should have EPP code of #{@expected}"
      end
    end

    def have_result(type, message = nil)
      code = ::EPP::Response::Result.codes.key(type)
      result = ::EPP::Response::Result.new(code, message)
      HaveResultMatcher.new(result)
    end
  end
end
