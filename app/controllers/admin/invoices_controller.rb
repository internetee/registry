module Admin
  class InvoicesController < BaseController
    load_and_authorize_resource

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

    def show; end

    def cancel
      @invoice.cancel
      redirect_to [:admin, @invoice], notice: t('.cancelled')
    end

    def download
      filename = "invoice-#{@invoice.number}.pdf"
      send_data @invoice.as_pdf, filename: filename
    end

    private

    def deposit_params
      params.require(:deposit).permit(:amount, :description, :registrar_id)
    end
  end
end
