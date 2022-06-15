module EisBilling
  class GetInvoiceNumber < EisBilling::Base
    def self.send_invoice
      send_request
    end

    def self.send_request
      http = EisBilling::Base.base_request(url: invoice_number_generator_url)
      http.post(invoice_number_generator_url, nil, EisBilling::Base.headers)

      response = http.post(invoice_number_generator_url, nil, EisBilling::Base.headers)
      logger(response)

      response
    end

    def self.invoice_number_generator_url
      "#{BASE_URL}/api/v1/invoice_generator/invoice_number_generator"
    end

    def self.logger(response)
      Rails.logger.info "--------* EIS Billing *--------"
      Rails.logger.info JSON.parse(response.body)['message']
      Rails.logger.info "-------------------------------"
    end
  end
end
