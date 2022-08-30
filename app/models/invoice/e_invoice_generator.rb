class Invoice
  class EInvoiceGenerator
    attr_reader :invoice, :payable

    def initialize(invoice, payable)
      @invoice = invoice
      @payable = payable
    end

    def generate
      seller = EInvoice::Seller.new
      seller.name = invoice.seller_name
      seller.registration_number = invoice.seller_reg_no
      seller.vat_number = invoice.seller_vat_no

      seller_legal_address = EInvoice::Address.new
      seller_legal_address.line1 = invoice.seller_street
      seller_legal_address.line2 = invoice.seller_state
      seller_legal_address.postal_code = invoice.seller_zip
      seller_legal_address.city = invoice.seller_city
      seller_legal_address.country = invoice.seller_country
      seller.legal_address = seller_legal_address

      buyer = EInvoice::Buyer.new
      buyer.name = invoice.buyer_name
      buyer.registration_number = invoice.buyer_reg_no
      buyer.vat_number = invoice.buyer_vat_no
      buyer.email = invoice.buyer.billing_email

      buyer_bank_account = EInvoice::BankAccount.new
      buyer_bank_account.number = invoice.buyer.e_invoice_iban
      buyer.bank_account = buyer_bank_account

      buyer_legal_address = EInvoice::Address.new
      buyer_legal_address.line1 = invoice.buyer_street
      buyer_legal_address.line2 = invoice.buyer_state
      buyer_legal_address.postal_code = invoice.buyer_zip
      buyer_legal_address.city = invoice.buyer_city
      buyer_legal_address.country = invoice.buyer_country
      buyer.legal_address = buyer_legal_address

      e_invoice_invoice_items = []
      invoice.each do |invoice_item|
        if invoice.monthly_invoice
          e_invoice_invoice_item = generate_monthly_invoice_item(invoice, invoice_item)
        else
          e_invoice_invoice_item = generate_normal_invoice_item(invoice_item)
        end
        e_invoice_invoice_items << e_invoice_invoice_item
      end

      e_invoice_invoice = EInvoice::Invoice.new.tap do |i|
        i.seller = seller
        i.buyer = buyer
        i.items = e_invoice_invoice_items
        i.number = invoice.number
        i.date = invoice.issue_date
        i.recipient_id_code = invoice.buyer_reg_no
        i.reference_number = invoice.reference_no
        i.due_date = invoice.due_date
        i.beneficiary_name = invoice.seller_name
        i.beneficiary_account_number = invoice.seller_iban
        i.payer_name = invoice.buyer_name
        i.subtotal = invoice.subtotal
        i.vat_amount = invoice.vat_amount
        i.total = invoice.total
        i.currency = invoice.currency
        i.delivery_channel = %i[internet_bank portal]
        i.payable = payable
        i.monthly_invoice = invoice.monthly_invoice
      end

      EInvoice::EInvoice.new(date: Time.zone.today, invoice: e_invoice_invoice)
    end

    private

    def generate_normal_invoice_item(item)
      EInvoice::InvoiceItem.new.tap do |i|
        i.description = item.description
        i.unit = item.unit
        i.price = item.price
        i.quantity = item.quantity
        i.subtotal = item.subtotal
        i.vat_rate = item.vat_rate
        i.vat_amount = item.vat_amount
        i.total = item.total
      end
    end

    def generate_monthly_invoice_item(invoice, item)
      EInvoice::InvoiceItem.new.tap do |i|
        i.description = item.description
        i.product_id = item.product_id
        i.unit = item.unit
        i.price = item.price
        i.quantity = item.quantity
        i.vat_rate = invoice.vat_rate
        if item.price && item.quantity
          i.subtotal = (item.price * item.quantity).round(3)
          i.vat_amount = i.subtotal * (i.vat_rate / 100)
          i.total = i.subtotal + i.vat_amount
        end
      end
    end
  end
end
