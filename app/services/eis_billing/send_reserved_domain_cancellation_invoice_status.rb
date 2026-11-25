module EisBilling
  class SendReservedDomainCancellationInvoiceStatus < EisBilling::Base
    attr_reader :domain_name, :token

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
      http.patch(reserved_domain_invoice_statuses_url, payload.to_json, EisBilling::Base.headers)
    end

    def payload
      {
        domain_name: domain_name,
        token: token
      }
    end

    def reserved_domain_invoice_statuses_url
      "#{EisBilling::Base::BASE_URL}/api/v1/invoice/reserved_domain_cancellation_statuses"
    end
  end
end
