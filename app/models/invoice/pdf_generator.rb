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
      view = ActionView::Base.new(ActionController::Base.view_paths, invoice: invoice)
      view.class_eval { include ApplicationHelper }
      view.render(file: 'invoice/pdf', layout: false)
    end
  end
end