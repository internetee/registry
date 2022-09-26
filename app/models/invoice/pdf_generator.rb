class Invoice
  class PdfGenerator
    attr_reader :invoice

    def initialize(invoice)
      @invoice = invoice
    end

    def as_pdf
      generator = PDFKit.new(invoice_html)
      generator.to_pdf
    end

    private

    def invoice_html
      template = invoice.monthly_invoice ? 'invoice/monthly_pdf' : 'invoice/pdf'
      ApplicationController.render(template: template, assigns: { invoice: invoice })
    end
  end
end
