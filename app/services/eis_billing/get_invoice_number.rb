module EisBilling
  class GetInvoiceNumber < EisBilling::Base
    def self.send_invoice
      send_request
    end

    private

    def self.send_request
      http = EisBilling::Base.base_request(url: invoice_number_generator_url)
      http.post(invoice_number_generator_url, nil, HEADERS)
    end

    def self.invoice_number_generator_url
      "#{BASE_URL}/api/v1/invoice_generator/invoice_number_generator"
    end
  end
end
