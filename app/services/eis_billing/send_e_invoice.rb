module EisBilling
  class SendEInvoice < EisBilling::Base
    def self.send_request(invoice:, payable:)
      base_request(invoice: invoice, payable: payable)
    end

    def self.base_request(invoice:, payable:)
      items = []
      prepared_data = {
        invoice: invoice,
        vat_amount: invoice.vat_amount,
        invoice_subtotal: invoice.subtotal,
        buyer_billing_email: invoice.buyer.billing_email,
        buyer_e_invoice_iban: invoice.buyer.e_invoice_iban,
        seller_country: invoice.seller_country,
        buyer_country: invoice.buyer_country,
        payable: payable,
        initiator: INITIATOR
      }

      invoice.items.each do |invoice_item|
        items << {
          description: invoice_item.description,
          price: invoice_item.price,
          quantity: invoice_item.quantity,
          unit: invoice_item.unit,
          subtotal: invoice_item.subtotal,
          vat_rate: invoice_item.vat_rate,
          vat_amount: invoice_item.vat_amount,
          total: invoice_item.total
        }
      end

      prepared_data[:items] = items

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
      "#{BASE_URL}/api/v1/e_invoice/e_invoice"
    end
  end
end
