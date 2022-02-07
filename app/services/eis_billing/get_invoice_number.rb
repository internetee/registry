module EisBilling
  class GetInvoiceNumber < EisBilling::Base
    def self.send_invoice
      result = base_request

      Rails.logger.info "---------->"
      Rails.logger.info result.body
      Rails.logger.info invoice_generator_url
      Rails.logger.info "---------->"

      result
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

      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      http.post(invoice_generator_url, nil, headers)
    end

    def self.invoice_generator_url
      "#{BASE_URL}/api/v1/invoice_generator/invoice_number_generator"
    end
  end
end
