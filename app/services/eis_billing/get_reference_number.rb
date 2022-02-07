module EisBilling
  class GetReferenceNumber < EisBilling::Base
    def self.send_request
      base_request
    end

    private

    def self.obj_data
      {
        initiator: INITIATOR
      }
    end

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
      
      http.post(invoice_generator_url, obj_data.to_json, headers)
    end

    def self.invoice_generator_url
      "#{BASE_URL}/api/v1/invoice_generator/reference_number_generator"
    end
  end
end
