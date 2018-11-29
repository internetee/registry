module Billing
  class ReferenceNo
    class Base
      def self.generate
        new(SecureRandom.random_number(1..1_000_000))
      end

      def initialize(base)
        @base = base.to_s
      end

      def check_digit
        amount = amount_after_multiplication
        next_number_ending_with_zero(amount) - amount
      end

      def to_s
        base
      end

      private

      attr_reader :base

      def next_number_ending_with_zero(number)
        next_number = number

        loop do
          next_number = next_number.next
          return next_number if next_number.to_s.end_with?('0')
        end
      end

      def amount_after_multiplication
        multipliers = [7, 3, 1]
        enumerator = multipliers.cycle
        amount = 0

        base.reverse.each_char do |char|
          digit = char.to_i
          amount += (digit * enumerator.next)
        end

        amount
      end
    end
  end
end
