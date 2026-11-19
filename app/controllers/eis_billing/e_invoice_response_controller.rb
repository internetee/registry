class EisBilling::EInvoiceResponseController < EisBilling::BaseController
  def update
    invoice = find_invoice(params[:invoice_number])
    return render status: :not_found, json: { message: 'Invoice not found' } if invoice.nil?

    invoice.update(e_invoice_sent_at: Time.zone.now)
    render status: :ok, json: { message: 'Response received' }
  end

  private

  def find_invoice(invoice_number)
    Invoice.find_by(number: invoice_number) ||
      Invoice.find_by(number: invoice_number.try(:[], 'invoice_number'))
  end
end
