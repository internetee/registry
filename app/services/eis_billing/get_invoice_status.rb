module EisBilling
  class GetInvoiceStatus < EisBilling::Base
    def self.send_invoice(invoice_number:)
      send_request(invoice_number: invoice_number)
    end

    private

    def self.send_request(invoice_number:)
      http = EisBilling::Base.base_request(url: invoice_number_generator_url)
      http.get(invoice_number_generator_url + "/#{invoice_number}", EisBilling::Base.headers)
    end

    def self.invoice_number_generator_url
      "#{BASE_URL}/api/v1/invoice_generator/invoice_status"
    end
  end
end
