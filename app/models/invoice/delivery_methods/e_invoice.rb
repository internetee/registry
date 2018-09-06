class Invoice
  module DeliveryMethods
    class EInvoice
      def deliver(invoices)
        e_invoice_invoices = []

        invoices.each do |invoice|
          seller = EstonianEInvoice::Seller.new
          seller.name = invoice.seller_name
          seller.reg_no = invoice.seller_reg_no

          buyer = EstonianEInvoice::Buyer.new
          buyer.name = invoice.buyer_name

          beneficiary = EstonianEInvoice::Beneficiary.new
          beneficiary.name = invoice.seller_name
          beneficiary.iban = invoice.seller_iban

          e_invoice_invoice_items = []

          invoice.invoice_items.each do |invoice_item|
            vat = if invoice.vat_rate
                    EstonianEInvoice::VAT::VAT.new(rate: invoice.vat_rate,
                                                   amount: invoice.vat_amount)
                  else
                    EstonianEInvoice::VAT::NoVAT.new
                  end

            e_invoice_invoice_item = EstonianEInvoice::InvoiceItem.new.tap do |i|
              i.description = invoice_item.description
              i.price = invoice_item.price
              i.quantity = invoice_item.amount
              i.unit = invoice_item.unit
              i.subtotal = invoice_item.item_sum_without_vat
              i.vat = vat
              i.total = invoice.total
            end
            e_invoice_invoice_items << e_invoice_invoice_item
          end

          e_invoice_invoice = EstonianEInvoice::Invoice.new(seller: seller,
                                                            buyer: buyer,
                                                            beneficiary: beneficiary,
                                                            items: e_invoice_invoice_items).tap do |i|
            i.number = invoice.number
            i.date = invoice.created_at.to_date
            i.recipient_id_code = invoice.buyer_reg_no
            i.reference_number = invoice.reference_no
            i.due_date = invoice.due_date.to_date
            i.payer_name = invoice.buyer_name
            i.subtotal = invoice.subtotal
            i.vat_rate = invoice.vat_rate
            i.vat_amount = invoice.vat_amount
            i.total = invoice.total
            i.currency = invoice.currency
            i.delivery_channel_address = invoice.buyer.auto_account_top_up_iban
          end

          e_invoice_invoices << e_invoice_invoice
        end

        e_invoice = EstonianEInvoice::EInvoice.new(e_invoice_invoices)
        e_invoice.deliver
      end
    end
  end
end
