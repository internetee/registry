module EisBilling
  class AddDeposits < EisBilling::Base
    attr_reader :invoice

    def initialize(invoice)
      @invoice = invoice
    end

    def call
      send_request(json_obj: parse_invoice)
    end

    private

    def parse_invoice
      data = {}

      data[:transaction_amount] = invoice.total.to_s
      data[:order_reference] = invoice.number
      data[:customer_name] = invoice.buyer_name
      data[:customer_email] = invoice.buyer_email
      data[:custom_field1] = invoice.user_unique_id || invoice.description
      data[:custom_field2] = invoice.is_a?(ActiveRecord::Base) ? EisBilling::Base::INITIATOR : (invoice&.initiator || EisBilling::Base::INITIATOR)
      data[:invoice_number] = invoice.number
      data[:reference_number] = invoice.reference_no
      data[:reserved_domain_names] = invoice.is_a?(ActiveRecord::Base) ? nil : invoice&.reserved_domain_names

      data
    end

    def send_request(json_obj:)
      http = EisBilling::Base.base_request
      http.post(invoice_generator_url, json_obj.to_json, EisBilling::Base.headers)
    end

    def invoice_generator_url
      "#{BASE_URL}/api/v1/invoice_generator/invoice_generator"
    end
  end
end
