module EisBilling
  class GetInvoiceNumber < EisBilling::Base
    def self.call
      send_request
    end

    def self.send_request
      http = EisBilling::Base.base_request
      http.post(invoice_number_generator_url, nil, EisBilling::Base.headers)
    end

    def self.invoice_number_generator_url
      "#{BASE_URL}/api/v1/invoice_generator/invoice_number_generator"
    end
  end
end
