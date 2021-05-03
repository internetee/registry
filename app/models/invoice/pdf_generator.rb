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
      ApplicationController.render(template: 'invoice/pdf', assigns: { invoice: invoice } )
    end
  end
end
