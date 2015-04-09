class Registrar::InvoicesController < RegistrarController
  load_and_authorize_resource

  before_action :set_invoice, only: [:show]

  def index
    @invoices = current_user.registrar.invoices.includes(:invoice_items)
  end

  def show
  end

  private

  def set_invoice
    @invoice = Invoice.find(params[:id])
  end
end
