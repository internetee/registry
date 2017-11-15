module EPP
  class Response
    class Result
      CODE_TO_TYPE = {
        '1000' => :success,
        '1001' => :success_pending,
        '1300' => :success_empty_queue,
        '1301' => :success_dequeue,
        '2001' => :syntax_error,
        '2003' => :required_param_missing,
        '2005' => :param_syntax_error,
        '2308' => :data_management_policy_violation
      }

      attr_accessor :code
      attr_accessor :message

      def initialize(code, message)
        @code = code
        @message = message
      end

      def self.codes
        CODE_TO_TYPE
      end
    end
  end
end
