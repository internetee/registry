module Epp
  class Response
    class Result
      attr_reader :code

      def initialize(code:)
        @code = code
      end
    end
  end
end
