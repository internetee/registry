module EisBilling
  class SendDataToDirecto < EisBilling::Base
    def self.send_request(object_data:, monthly:, dry:)
      base_request(object_data: object_data, monthly: monthly, dry: dry)
    end

    def self.base_request(object_data:, monthly:, dry:)
      prepared_data = {
        invoice_data: object_data,
        monthly: monthly,
        dry: dry,
        initiator: INITIATOR
      }

      uri = URI(invoice_generator_url)
      http = Net::HTTP.new(uri.host, uri.port)
      headers = {
        'Authorization' => 'Bearer foobar',
        'Content-Type' => 'application/json',
        'Accept' => TOKEN
      }

      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      http.post(invoice_generator_url, prepared_data.to_json, headers)
    end

    def self.invoice_generator_url
      "#{BASE_URL}/api/v1/directo/directo"
    end
  end
end
