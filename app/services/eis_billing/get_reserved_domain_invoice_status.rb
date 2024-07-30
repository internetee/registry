module EisBilling
  class GetReservedDomainInvoiceStatus < EisBilling::Base
    attr_reader :domain_name, :token

    PAID = 'paid'.freeze
    OK = '200'.freeze
    CREATED = '201'.freeze

    # rubocop:disable Lint/MissingSuper
    def initialize(domain_name:, token:)
      @domain_name = domain_name
      @token = token
    end

    def self.call(domain_name:, token:)
      new(domain_name: domain_name, token: token).call
    end

    def call
      http = EisBilling::Base.base_request
      res = http.get(reserved_domain_invoice_statuses_url, EisBilling::Base.headers)

      puts '----'
      puts res.body
      puts '----'

      wrap_result(res)
    end

    def wrap_result(result)
      parsed_result = JSON.parse(result.body)
      Struct.new(:message, :status, :paid?, :status_code_success, :invoice_number)
        .new(parsed_result['message'], parsed_result['invoice_status'], parsed_result['invoice_status'] == PAID, result.code == OK || result.code == CREATED, parsed_result['invoice_number'])
    end

    def reserved_domain_invoice_statuses_url
      "#{EisBilling::Base::BASE_URL}/api/v1/invoice/reserved_domain_invoice_statuses?domain_name=#{domain_name}&token=#{token}"
    end
  end
end
