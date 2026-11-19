module EisBilling
  class SendDataToDirecto < EisBilling::Base
    def self.send_request(object_data:, monthly: false, dry: false, initiator: INITIATOR)
      send_info(object_data: object_data, monthly: monthly, dry: dry, initiator: initiator)
    end

    def self.send_info(object_data:, monthly:, dry:, initiator:)
      prepared_data = {
        invoice_data: object_data,
        monthly: monthly,
        dry: dry,
        initiator: initiator,
      }

      http = EisBilling::Base.base_request
      http.post(directo_url, prepared_data.to_json, EisBilling::Base.headers)
    end

    def self.directo_url
      "#{BASE_URL}/api/v1/directo/directo"
    end
  end
end
