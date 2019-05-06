module Deliverable
  extend ActiveSupport::Concern

  included do
    before_action :find_invoice
  end

  def new
    authorize! :manage, @invoice
    @recipient = @invoice.registrar.billing_email
  end

  def create
    authorize! :manage, @invoice

    InvoiceMailer.invoice_email(invoice: @invoice, recipient: params[:recipient]).deliver_now

    redirect_to redirect_url, notice: t('.delivered')
  end

  private

  def find_invoice
    @invoice = Invoice.find(params[:invoice_id])
  end
end