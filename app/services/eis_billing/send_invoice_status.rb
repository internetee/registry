module EisBilling
  class SendInvoiceStatus < EisBilling::Base
    def self.send_info(invoice_number:, status:)
      send_request(invoice_number: invoice_number, status: status)
    end

    def self.send_request(invoice_number:, status:)
      json_obj = {
        invoice_number: invoice_number,
        status: status,
      }

      http = EisBilling::Base.base_request(url: invoice_status_url)
      http.post(invoice_status_url, json_obj.to_json, EisBilling::Base.headers)
    end

    def self.invoice_status_url
      "#{BASE_URL}/api/v1/invoice_generator/invoice_status"
    end
  end
end
