module Admin
  class InvoicesController < BaseController
    load_and_authorize_resource

    before_action :set_invoice, only: [:forward, :download_pdf]

    def new
      @deposit = Deposit.new
    end

    def create
      r = Registrar.find_by(id: deposit_params[:registrar_id])
      @deposit = Deposit.new(deposit_params.merge(registrar: r))
      @invoice = @deposit.issue_prepayment_invoice

      if @invoice&.persisted?
        flash[:notice] = t(:record_created)
        redirect_to [:admin, @invoice]
      else
        flash.now[:alert] = t(:failed_to_create_record)
        render 'new'
      end
    end

    def index
      @q = Invoice.includes(:account_activity).search(params[:q])
      @q.sorts = 'number desc' if @q.sorts.empty?
      @invoices = @q.result.page(params[:page])
    end

    def show
      @invoice = Invoice.find(params[:id])
    end

    def cancel
      if @invoice.cancel
        flash[:notice] = t(:record_updated)
        redirect_to([:admin, @invoice])
      else
        flash.now[:alert] = t(:failed_to_update_record)
        render :show
      end
    end

    def forward
      @invoice.billing_email = @invoice.buyer.billing_email

      return unless request.post?

      @invoice.billing_email = params[:invoice][:billing_email]

      if @invoice.forward(render_to_string('registrar/invoices/pdf', layout: false))
        flash[:notice] = t(:invoice_forwared)
        redirect_to([:admin, @invoice])
      else
        flash.now[:alert] = t(:failed_to_forward_invoice)
      end
    end

    def download_pdf
      pdf = @invoice.pdf(render_to_string('registrar/invoices/pdf', layout: false))
      send_data pdf, filename: @invoice.pdf_name
    end

    private

    def deposit_params
      params.require(:deposit).permit(:amount, :description, :registrar_id)
    end

    def set_invoice
      @invoice = Invoice.find(params[:invoice_id])
    end
  end
end
