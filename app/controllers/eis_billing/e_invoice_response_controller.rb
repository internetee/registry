class EisBilling::EInvoiceResponseController < ApplicationController
  def update
    invoice_number = params[:invoice_number]
    date = params[:date]

    set_e_invoice_sent_at(date, invoice_number)
    render status: 200, json: { messege: 'Response received', status: :ok }
  end

  private

  def set_e_invoice_sent_at(date, invoice_number)
    invoice = Invoice.find_by(number: invoice_number)
    invoice.update(e_invoice_sent_at: Time.zone.now)
  end
end
