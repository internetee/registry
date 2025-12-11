require 'test_helper'

module EisBilling
  class SendReservedDomainCancellationInvoiceStatusTest < ActiveSupport::TestCase
    def setup
      @domain_name = 'example.com'
      @token = 'test_token'
      @service = SendReservedDomainCancellationInvoiceStatus.new(domain_name: @domain_name, token: @token)
    end

    def test_initialization
      assert_equal @domain_name, @service.domain_name
      assert_equal @token, @service.token
    end

    def test_payload
      expected_payload = { domain_name: @domain_name, token: @token }
      assert_equal expected_payload, @service.payload
    end

    def test_reserved_domain_invoice_statuses_url
      expected_url = "#{EisBilling::Base::BASE_URL}/api/v1/invoice/reserved_domain_cancellation_statuses"
      assert_equal expected_url, @service.reserved_domain_invoice_statuses_url
    end

    def test_call_sends_patch_request
      mock_http = Minitest::Mock.new
      mock_response = Minitest::Mock.new

      EisBilling::Base.stub :base_request, mock_http do
        mock_http.expect :patch, mock_response, [
          @service.reserved_domain_invoice_statuses_url,
          @service.payload.to_json,
          EisBilling::Base.headers
        ]

        @service.call
      end

      mock_http.verify
    end

    def test_class_method_call
      mock_http = Minitest::Mock.new
      mock_response = Object.new
      mock_http.expect(:patch, mock_response, [String, String, Hash])
    
      EisBilling::Base.stub :base_request, mock_http do
        result = SendReservedDomainCancellationInvoiceStatus.call(domain_name: @domain_name, token: @token)
        assert_equal mock_response, result
      end
    
      mock_http.verify
    end
  end
end
