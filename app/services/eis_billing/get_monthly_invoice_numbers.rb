module EisBilling
  class GetMonthlyInvoiceNumbers < EisBilling::Base
    def self.send_request(count)
      prepared_data = {
        count: count,
      }
      http = EisBilling::Base.base_request(url: invoice_numbers_generator_url)
      http.post(invoice_numbers_generator_url, prepared_data.to_json, EisBilling::Base.headers)
    end

    def self.invoice_numbers_generator_url
      "#{BASE_URL}/api/v1/invoice_generator/monthly_invoice_numbers_generator"
    end
  end
end
