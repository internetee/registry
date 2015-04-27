class Registrar::InvoicesController < RegistrarController
  load_and_authorize_resource

  before_action :set_invoice, only: [:show, :forward, :download_pdf]

  def index
    invoices = current_user.registrar.invoices.includes(:invoice_items, :account_activity)
    @q = invoices.search(params[:q])
    @q.sorts  = 'id desc' if @q.sorts.empty?
    @invoices = @q.result.page(params[:page])
  end

  def show
  end

  def forward
    @invoice.billing_email = @invoice.buyer.billing_email

    return unless request.post?

    @invoice.billing_email = params[:invoice][:billing_email]

    if @invoice.forward(render_to_string('pdf', layout: false))
      flash[:notice] = t('invoice_forwared')
      redirect_to([:registrar, @invoice])
    else
      flash.now[:alert] = t('failed_to_forward_invoice')
    end
  end

  def cancel
    if @invoice.cancel
      flash[:notice] = t('record_updated')
      redirect_to([:registrar, @invoice])
    else
      flash.now[:alert] = t('failed_to_update_record')
      render :show
    end
  end

  def download_pdf
    # render 'pdf', layout: false

    pdf = @invoice.pdf(render_to_string('pdf', layout: false))
    send_data pdf, filename: @invoice.pdf_name
  end

  private

  def set_invoice
    @invoice = Invoice.find(params[:id])
  end
end
