module EisBilling
  class GetReferenceNumber < EisBilling::Base
    def self.send_request
      send_request
    end

    private

    def self.obj_data
      {
        initiator: INITIATOR
      }
    end

    def self.send_request
      http = EisBilling::Base.base_request(url: reference_number_generator_url)
      http.post(reference_number_generator_url, obj_data.to_json, HEADERS)
    end

    def self.reference_number_generator_url
      "#{BASE_URL}/api/v1/invoice_generator/reference_number_generator"
    end
  end
end
