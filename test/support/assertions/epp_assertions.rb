module Assertions
  module EppAssertions
    def assert_epp_response(code_key, message = nil)
      assert epp_response.code?(Epp::Response::Result::Code.key(code_key)), message
    end

    private

    def epp_response
      @epp_response = Epp::Response.xml(response.body) unless @epp_response
      @epp_response
    end
  end
end
