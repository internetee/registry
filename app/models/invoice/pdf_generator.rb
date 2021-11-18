# frozen_string_literal: true

require 'rqrcode'

class Invoice
  class PdfGenerator
    attr_reader :invoice

    def initialize(invoice)
      @invoice = invoice
    end

    def as_pdf
      generator = PDFKit.new(invoice_html)
      generate_qr unless @invoice.paid?
      generator.to_pdf
    end

    private

    def invoice_html
      ApplicationController.render(template: 'invoice/pdf', assigns: { invoice: invoice })
    end

    def generate_qr
      return unless @invoice.qr_enabled?

      qrcode = RQRCode::QRCode.new(@invoice.linkpay_url)

      # NOTE: showing with default options specified explicitly
      png = qrcode.as_png(
        bit_depth: 1,
        border_modules: 4,
        color_mode: ChunkyPNG::COLOR_GRAYSCALE,
        color: 'black',
        file: nil,
        fill: 'white',
        module_px_size: 6,
        resize_exactly_to: false,
        resize_gte_to: false,
        size: 240
      )

      path = "#{Rails.root}/public/#{@invoice.number}.png"
      IO.binwrite(path, png.to_s)
    end
  end
end
