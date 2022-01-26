module EisBilling
  class GetInvoiceNumber < EisBilling::Base
    attr_reader :invoice

    def self.send_invoice
      base_request
    end

    private

    def self.base_request
      uri = URI(invoice_generator_url)
      http = Net::HTTP.new(uri.host, uri.port)
      headers = {
        'Authorization' => 'Bearer foobar',
        'Content-Type' => 'application/json',
        'Accept' => TOKEN
      }

      http.post(invoice_generator_url, nil, headers)
    end

    def self.invoice_generator_url
      "#{BASE_URL}/api/v1/invoice_generator/invoice_number_generator"
    end
  end
end
