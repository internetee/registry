module EisBilling
  class SendEInvoice < EisBilling::Base
    def self.send_request(invoice:, payable:)
      send_info(invoice: invoice, payable: payable)
    end

    def self.send_info(invoice:, payable:)
      prepared_data = prepare_data(invoice: invoice, payable: payable)

      http = EisBilling::Base.base_request(url: e_invoice_url)
      http.post(e_invoice_url, prepared_data.to_json, EisBilling::Base.headers)
    end

    def self.prepare_items(invoice)
      if invoice.monthly_invoice
        invoice.metadata['items']
      else
        invoice.items.map do |invoice_item|
          {
            description: invoice_item.description,
            price: invoice_item.price,
            quantity: invoice_item.quantity,
            unit: invoice_item.unit,
            subtotal: invoice_item.subtotal,
            vat_rate: invoice_item.vat_rate,
            vat_amount: invoice_item.vat_amount,
            total: invoice_item.total,
          }
        end
      end
    end

    def self.prepare_data(invoice:, payable:)
      {
        invoice: invoice.as_json,
        vat_amount: invoice.vat_amount,
        invoice_subtotal: invoice.subtotal,
        buyer_billing_email: invoice.buyer.billing_email,
        buyer_e_invoice_iban: invoice.buyer.e_invoice_iban,
        seller_country_code: invoice.seller_country_code,
        buyer_country_code: invoice.buyer_country_code,
        payable: payable,
        initiator: EisBilling::Base::INITIATOR,
        items: prepare_items(invoice),
      }
    end

    def self.e_invoice_url
      "#{BASE_URL}/api/v1/e_invoice/e_invoice"
    end
  end
end
