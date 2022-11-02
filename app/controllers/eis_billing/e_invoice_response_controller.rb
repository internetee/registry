class EisBilling::EInvoiceResponseController < EisBilling::BaseController
  def update
    invoice_number = params[:invoice_number]

    mark_e_invoice_sent_at(invoice_number)
    render status: :ok, json: { message: 'Response received' }
  end

  private

  def mark_e_invoice_sent_at(invoice_number)
    invoice = Invoice.find_by(number: invoice_number)
    invoice = Invoice.find_by(number: invoice_number['invoice_number']) if invoice.nil?

    invoice.update(e_invoice_sent_at: Time.zone.now)
  end
end
