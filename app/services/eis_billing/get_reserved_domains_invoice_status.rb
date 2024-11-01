module EisBilling
  class GetReservedDomainsInvoiceStatus < EisBilling::Base
    attr_reader :invoice_number

    PAID = 'paid'.freeze
    OK = '200'.freeze
    CREATED = '201'.freeze

    # rubocop:disable Lint/MissingSuper
    def initialize(invoice_number:)
      @invoice_number = invoice_number
    end

    def self.call(invoice_number:)
      new(invoice_number: invoice_number).call
    end

    def call
      http = EisBilling::Base.base_request
      res = http.get(reserved_domain_invoice_statuses_url, EisBilling::Base.headers)

      wrap_result(res)
    end

    def wrap_result(result)
      parsed_result = JSON.parse(result.body)

      Struct.new(:message, :status, :paid?, :status_code_success, :invoice_number, :details)
        .new(parsed_result['message'], parsed_result['invoice_status'], parsed_result['invoice_status'] == PAID, result.code == OK || result.code == CREATED, parsed_result['invoice_number'], parsed_result['details'])
    end

    def reserved_domain_invoice_statuses_url
      "#{EisBilling::Base::BASE_URL}/api/v1/invoice/reserved_domains_invoice_statuses?invoice_number=#{invoice_number}"
    end
  end
end
