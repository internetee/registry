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
      {
        transaction_amount: invoice.total.to_s,
        order_reference: invoice.number,
        customer_name: invoice.buyer_name,
        customer_email: invoice.buyer_email,
        custom_field1: custom_field1_value,
        custom_field2: custom_field2_value,
        invoice_number: invoice.number,
        reference_number: invoice.reference_no,
        reserved_domain_names: reserved_domain_names
      }
    end

    def custom_field1_value
      if invoice.is_a?(ActiveRecord::Base)
        invoice.description
      else
        invoice.respond_to?(:user_unique_id) ? invoice.user_unique_id : invoice.description
      end
    end

    def custom_field2_value
      invoice.is_a?(ActiveRecord::Base) ? 
        EisBilling::Base::INITIATOR : 
        (invoice&.initiator || EisBilling::Base::INITIATOR)
    end

    def reserved_domain_names
      invoice.is_a?(ActiveRecord::Base) ? nil : invoice&.reserved_domain_names
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
