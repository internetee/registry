module EisBilling
  class DirectoDataSender < EisBilling::Base
    def self.send_data(object_data:, invoice_number:)
      send_info(object_data: object_data, invoice_number: invoice_number)
    end

    def self.send_info(object_data:, invoice_number:)
      prepared_data = {
        invoice_number: invoice_number,
        invoice_data: object_data,
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
