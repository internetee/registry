class ReserveDomainInvoice
  class PdfGenerator
    attr_reader :invoice, :customer_name, :customer_address, :customer_vat_no

    delegate :reference_no, :due_date, :vat_amount, :net_price_per_domain, to: :invoice

    # Buyer details sent with the request win over the stored ones
    def initialize(invoice, context = {})
      @invoice = invoice
      @customer_name = context[:customer_name] || invoice.buyer_name
      @customer_address = context[:customer_address] || invoice.buyer_address
      @customer_vat_no = context[:customer_vat_no] || invoice.buyer_vat_no
      @private_individual = context[:private_individual]
      @payment_date = context[:payment_date] || invoice.paid_at&.to_date
      @paid = context[:paid]
    end

    def paid?
      !!@paid
    end

    def payment_date
      @payment_date if paid?
    end

    def amount_paid
      grand_total
    end

    def as_pdf
      PDFKit.new(html, enable_local_file_access: true).to_pdf
    end

    def rows
      invoice.domain_names.map { |name| { name: name, reserved: paid?, price: net_price_per_domain } }
    end

    def rows_sum
      invoice.subtotal
    end

    def vat_rate
      invoice.vat_rate.to_f
    end

    def grand_total
      invoice.total
    end

    def invoice_date
      invoice.created_at&.to_date || Date.current
    end

    def private_individual?
      !!@private_individual
    end

    private

    def html
      ApplicationController.render(template: 'reserve_domain_invoices/pdf', assigns: { pdf: self })
    end
  end
end
