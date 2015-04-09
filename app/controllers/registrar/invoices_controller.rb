class Registrar::InvoicesController < RegistrarController
  load_and_authorize_resource

  before_action :set_invoice, only: [:show]

  def index
  end

  def show
  end

  private

  def set_invoice
    @invoice = Invoice.find(params[:id])
  end
end
