class ReserveDomainInvoice
  class PdfGenerator
    attr_reader :invoice, :customer_name, :customer_address, :customer_vat_no, :payment_date

    def initialize(invoice, context = {})
      @invoice = invoice
      @customer_name = context[:customer_name]
      @customer_address = context[:customer_address]
      @customer_vat_no = context[:customer_vat_no]
      @private_individual = context[:private_individual]
      @payment_date = context[:payment_date]
    end

    def amount_paid
      grand_total
    end

    def as_pdf
      PDFKit.new(html, enable_local_file_access: true).to_pdf
    end

    def rows
      invoice.domain_names.map { |name| { name: name, reserved: true, price: net_price_per_domain } }
    end

    def rows_sum
      rows.sum { |row| row[:price] }
    end

    def vat_rate
      Setting.registry_vat_prc.to_f
    end

    def vat_amount
      (grand_total - rows_sum).round(2)
    end

    def grand_total
      (invoice.domain_names.size * ReserveDomainInvoice::DEFAULT_AMOUNT).round(2)
    end

    def invoice_date
      invoice.created_at&.to_date || Date.current
    end

    def private_individual?
      !!@private_individual
    end

    private

    def net_price_per_domain
      (ReserveDomainInvoice::DEFAULT_AMOUNT / (1 + vat_rate)).round(2)
    end

    def html
      ApplicationController.render(template: 'reserve_domain_invoices/pdf', assigns: { pdf: self })
    end
  end
end
