module EisBilling
  class SendDataToDirecto < EisBilling::Base
    def self.send_request(object_data:, monthly:, dry:)
      send_info(object_data: object_data, monthly: monthly, dry: dry)
    end

    def self.send_info(object_data:, monthly:, dry:)
      prepared_data = {
        invoice_data: object_data,
        monthly: monthly,
        dry: dry,
        initiator: INITIATOR
      }

      http = EisBilling::Base.base_request(url: directo_url)
      http.post(directo_url, prepared_data.to_json, EisBilling::Base.headers)
    end

    def self.directo_url
      "#{BASE_URL}/api/v1/directo/directo"
    end
  end
end
